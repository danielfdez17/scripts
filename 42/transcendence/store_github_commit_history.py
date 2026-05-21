#!/usr/bin/env python3

"""Collect commit history from local Git repositories into SQLite.

The script accepts local repository paths either as positional arguments or
through a text file, stores commit history in SQLite, keeps per-committer
counts, and generates the HTML report after collection finishes.
"""

import argparse
import sqlite3
import subprocess
import sys
import webbrowser
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import DefaultDict, Optional, Tuple


DEFAULT_DB_PATH = "github_commit_history.sqlite3"
DEFAULT_REPORT_PATH = "github_commit_history_report.html"
GIT_LOG_FORMAT = "%H%x1f%cn%x1f%ce%x1f%cd%x1f%an%x1f%ae%x1f%ad%x1f%s"
GIT_LOG_SEPARATOR = "\x1f"


class GitRepositoryError(RuntimeError):
    """Raised when a local repository cannot be collected."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Store commit history from local Git repositories in SQLite."
    )
    parser.add_argument(
        "repos",
        nargs="*",
        help="Local repository paths. You can also provide them through --repos-file.",
    )
    parser.add_argument(
        "--repos-file",
        help=(
            "Path to a text file with one local repository path per line. Blank lines "
            "and lines starting with # are ignored."
        ),
    )
    parser.add_argument(
        "--db",
        default=DEFAULT_DB_PATH,
        help=f"Path to the SQLite database file (default: {DEFAULT_DB_PATH}).",
    )
    parser.add_argument(
        "--report-output",
        default=DEFAULT_REPORT_PATH,
        help=f"Path to the HTML report to generate (default: {DEFAULT_REPORT_PATH}).",
    )
    return parser.parse_args()


def load_repositories_from_file(file_path: str) -> list[str]:
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Repositories file not found: {path}")

    repositories = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        repositories.append(line)
    return repositories


def collect_input_repositories(args: argparse.Namespace) -> list[str]:
    if args.repos:
        return list(args.repos)
    if args.repos_file:
        return load_repositories_from_file(args.repos_file)
    raise ValueError("You must provide repositories with --repos-file or as positional arguments.")


def ensure_schema(connection: sqlite3.Connection) -> None:
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript(
        """
        CREATE TABLE IF NOT EXISTS repositories (
            full_name TEXT PRIMARY KEY,
            last_collected_at TEXT NOT NULL,
            last_status TEXT NOT NULL,
            last_error TEXT,
            commit_total INTEGER NOT NULL DEFAULT 0,
            committer_total INTEGER NOT NULL DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS commits (
            repo_full_name TEXT NOT NULL,
            sha TEXT NOT NULL,
            committer_key TEXT NOT NULL,
            committer_name TEXT NOT NULL,
            author_name TEXT,
            author_email TEXT,
            committed_at TEXT,
            authored_at TEXT,
            message TEXT,
            url TEXT,
            PRIMARY KEY (repo_full_name, sha),
            FOREIGN KEY (repo_full_name) REFERENCES repositories(full_name) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS committer_counts (
            repo_full_name TEXT NOT NULL,
            committer_key TEXT NOT NULL,
            committer_name TEXT NOT NULL,
            committer_email TEXT,
            commit_count INTEGER NOT NULL,
            PRIMARY KEY (repo_full_name, committer_key),
            FOREIGN KEY (repo_full_name) REFERENCES repositories(full_name) ON DELETE CASCADE
        );
        """
    )


def record_repository_status(
    connection: sqlite3.Connection,
    full_name: str,
    status: str,
    error_message: Optional[str],
    commit_total: int,
    committer_total: int,
) -> None:
    connection.execute(
        """
        INSERT INTO repositories (
            full_name, last_collected_at, last_status, last_error, commit_total, committer_total
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(full_name) DO UPDATE SET
            last_collected_at=excluded.last_collected_at,
            last_status=excluded.last_status,
            last_error=excluded.last_error,
            commit_total=excluded.commit_total,
            committer_total=excluded.committer_total
        """,
        (
            full_name,
            datetime.now(timezone.utc).isoformat(),
            status,
            error_message,
            commit_total,
            committer_total,
        ),
    )


def normalize_repository_path(reference: str) -> Path:
    path = Path(reference).expanduser()
    if not path.exists():
        raise GitRepositoryError(f"Repository path does not exist: {reference}")
    if not path.is_dir():
        raise GitRepositoryError(f"Repository path is not a directory: {reference}")
    return path.resolve()


def run_git_command(repository_path: Path, args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repository_path), *args],
        capture_output=True,
        text=True,
        check=True,
    )


def repository_display_name(repository_path: Path) -> str:
    try:
        remote = run_git_command(repository_path, ["remote", "get-url", "origin"]).stdout.strip()
    except subprocess.CalledProcessError:
        return repository_path.name

    if remote.endswith(".git"):
        remote = remote[:-4]

    if remote.startswith("git@github.com:"):
        remote = remote.removeprefix("git@github.com:")
    elif remote.startswith(("https://github.com/", "http://github.com/")):
        remote = remote.split("github.com/", 1)[-1]

    parts = [part for part in remote.strip("/").split("/") if part]
    if len(parts) >= 2:
        return f"{parts[-2]}/{parts[-1]}"
    return repository_path.name


def parse_git_log_line(line: str) -> Tuple[str, str, str, str, str, str, str, str]:
    fields = line.split(GIT_LOG_SEPARATOR, 7)
    if len(fields) != 8:
        raise GitRepositoryError("Unexpected git log output format")
    return (
        fields[0],
        fields[1],
        fields[2],
        fields[3],
        fields[4],
        fields[5],
        fields[6],
        fields[7],
    )


def fetch_commits(repository_path: Path):
    try:
        result = run_git_command(
            repository_path,
            ["log", "--all", f"--pretty=format:{GIT_LOG_FORMAT}", "--date=iso-strict"],
        )
    except subprocess.CalledProcessError as error:
        stderr = error.stderr.strip() if error.stderr else ""
        message = stderr or f"Failed to read git history for {repository_path}"
        raise GitRepositoryError(message) from error

    for raw_line in result.stdout.splitlines():
        if not raw_line.strip():
            continue
        yield parse_git_log_line(raw_line)


def committer_key(name: str, email: str) -> str:
    if email:
        return f"email:{email.lower()}"
    return f"name:{name.lower()}"


def store_repository(connection: sqlite3.Connection, repository_reference: str) -> bool:
    commit_counts: DefaultDict[str, int] = defaultdict(int)
    committer_names: dict[str, str] = {}
    committer_emails: dict[str, str] = {}
    commit_total = 0

    try:
        repository_path = normalize_repository_path(repository_reference)
        full_name = str(repository_path)
        display_name = repository_display_name(repository_path)

        print(f"Collecting {display_name} ({repository_path})...")

        with connection:
            record_repository_status(connection, full_name, "collecting", None, 0, 0)
            connection.execute("DELETE FROM commits WHERE repo_full_name = ?", (full_name,))
            connection.execute("DELETE FROM committer_counts WHERE repo_full_name = ?", (full_name,))

            for sha, committer_name, committer_email, committed_at, author_name, author_email, authored_at, message in fetch_commits(repository_path):
                key = committer_key(committer_name, committer_email)
                commit_counts[key] += 1
                committer_names[key] = committer_name
                committer_emails[key] = committer_email or ""
                commit_total += 1

                connection.execute(
                    """
                    INSERT OR REPLACE INTO commits (
                        repo_full_name, sha, committer_key, committer_name,
                        author_name, author_email, committed_at, authored_at, message, url
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        full_name,
                        sha,
                        key,
                        committer_name,
                        author_name or None,
                        author_email or None,
                        committed_at,
                        authored_at,
                        message,
                        sha,
                    ),
                )

            for key, count in commit_counts.items():
                connection.execute(
                    """
                    INSERT OR REPLACE INTO committer_counts (
                        repo_full_name, committer_key, committer_name, committer_email, commit_count
                    ) VALUES (?, ?, ?, ?, ?)
                    """,
                    (full_name, key, committer_names[key], committer_emails[key], count),
                )

            record_repository_status(connection, full_name, "success", None, commit_total, len(commit_counts))

        print(f"Stored {commit_total} commits for {display_name}.")
        return True
    except (GitRepositoryError, sqlite3.Error, OSError, ValueError) as error:
        full_name = str(Path(repository_reference).expanduser())
        print(f"Failed to collect {full_name}: {error}")
        try:
            with connection:
                record_repository_status(connection, full_name, "error", str(error), 0, 0)
        except sqlite3.Error as status_error:
            print(f"Failed to record status for {full_name}: {status_error}")
        return False


def generate_report(db_path: str, report_output: str) -> None:
    report_script = Path(__file__).with_name("visualize_github_commit_history.py")
    subprocess.run(
        [
            sys.executable,
            str(report_script),
            "--db",
            db_path,
            "--output",
            report_output,
        ],
        check=True,
    )
    webbrowser.open(Path(report_output).resolve().as_uri())


def main() -> int:
    args = parse_args()
    try:
        repositories = collect_input_repositories(args)
    except (FileNotFoundError, ValueError) as error:
        print(error)
        return 1

    if not repositories:
        print("You must provide at least one repository.")
        return 1

    try:
        connection = sqlite3.connect(args.db)
    except sqlite3.Error as error:
        print(f"Unable to open database '{args.db}': {error}")
        return 1

    success_count = 0
    failure_count = 0

    try:
        ensure_schema(connection)
        for repository in repositories:
            if store_repository(connection, repository):
                success_count += 1
            else:
                failure_count += 1
    finally:
        connection.close()

    try:
        generate_report(args.db, args.report_output)
    except subprocess.CalledProcessError as error:
        print(f"Failed to generate the HTML report: {error}")
    except Exception as error:
        print(f"Failed to open the HTML report in a browser: {error}")

    print(
        f"Finished. Successful repositories: {success_count}. Failed repositories: {failure_count}."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
