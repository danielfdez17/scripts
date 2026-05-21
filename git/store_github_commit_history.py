#!/usr/bin/env python3

"""Collect GitHub commit history into SQLite.

The script accepts a list of repositories, fetches their commit history from the
GitHub API, stores the raw commit rows, and keeps an aggregated count of commits
per committer. Repository-level failures are isolated so one private or
unreachable repository does not stop the rest of the run.
"""

import argparse
import json
import os
import subprocess
import sqlite3
import sys
import webbrowser
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import DefaultDict, Optional, Tuple
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlparse
from urllib.request import Request, urlopen


API_VERSION = "2022-11-28"
DEFAULT_DB_PATH = "github_commit_history.sqlite3"
DEFAULT_REPORT_PATH = "github_commit_history_report.html"
GITHUB_API_BASE = "https://api.github.com"


class GitHubRepositoryError(RuntimeError):
    """Raised when a repository cannot be collected."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Store GitHub commit history and per-committer counts in SQLite."
    )
    parser.add_argument(
        "repos",
        nargs="*",
        help=(
            "Repository identifiers. Accepted formats: owner/repo, "
            "https://github.com/owner/repo, or git@github.com:owner/repo.git"
        ),
    )
    parser.add_argument(
        "--repos-file",
        help="Path to a text file with one repository per line. Blank lines and lines starting with # are ignored.",
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
    parser.add_argument(
        "--token",
        default=os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN"),
        help="GitHub token for private repositories. Defaults to GITHUB_TOKEN or GH_TOKEN.",
    )
    return parser.parse_args()


def load_repositories_from_file(file_path: str):
    repositories = []
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Repositories file not found: {path}")

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        repositories.append(line)

    return repositories


def normalize_repository(reference: str) -> Tuple[str, str]:
    reference = reference.strip()

    if reference.startswith("git@github.com:"):
        reference = reference.removeprefix("git@github.com:")
    else:
        parsed = urlparse(reference)
        if parsed.scheme and parsed.netloc:
            if parsed.netloc not in {"github.com", "www.github.com"}:
                raise GitHubRepositoryError(f"Unsupported host in repository reference: {reference}")
            reference = parsed.path

    reference = reference.strip("/")
    if reference.endswith(".git"):
        reference = reference[:-4]

    parts = [part for part in reference.split("/") if part]
    if len(parts) != 2:
        raise GitHubRepositoryError(
            f"Invalid repository reference '{reference}'. Expected owner/repo or a GitHub URL."
        )

    return parts[0], parts[1]


def github_request(url: str, token: Optional[str]) -> str:
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": API_VERSION,
        "User-Agent": "scripts-commit-history-collector",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    request = Request(url, headers=headers)
    with urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def build_commits_url(owner: str, repo: str, page: int, per_page: int) -> str:
    return (
        f"{GITHUB_API_BASE}/repos/{quote(owner, safe='')}/{quote(repo, safe='')}"
        f"/commits?per_page={per_page}&page={page}"
    )


def load_commit_page(owner: str, repo: str, token: Optional[str], page: int, per_page: int):
    url = build_commits_url(owner, repo, page, per_page)

    try:
        payload = github_request(url, token)
    except HTTPError as error:
        if error.code == 409:
            return []
        if error.code in {403, 404}:
            raise GitHubRepositoryError(
                f"GitHub API returned {error.code} while reading {owner}/{repo}. "
                "The repository may be private or unavailable."
            ) from error
        raise GitHubRepositoryError(
            f"GitHub API error {error.code} while reading {owner}/{repo}"
        ) from error
    except URLError as error:
        raise GitHubRepositoryError(f"Network error while reading {owner}/{repo}: {error.reason}") from error

    try:
        commits = json.loads(payload)
    except ValueError as error:
        raise GitHubRepositoryError(f"Invalid JSON received for {owner}/{repo}") from error

    if not isinstance(commits, list):
        raise GitHubRepositoryError(f"Unexpected API response while reading {owner}/{repo}")

    return commits


def fetch_commits(owner: str, repo: str, token: Optional[str]):
    page = 1
    per_page = 100

    while True:
        commits = load_commit_page(owner, repo, token, page, per_page)

        if not commits:
            return

        for commit in commits:
            yield commit

        if len(commits) < per_page:
            return

        page += 1


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
            commit_count INTEGER NOT NULL,
            PRIMARY KEY (repo_full_name, committer_key),
            FOREIGN KEY (repo_full_name) REFERENCES repositories(full_name) ON DELETE CASCADE
        );
        """
    )


def extract_committer_info(commit: dict) -> Tuple[str, str, Optional[str], Optional[str], Optional[str], Optional[str]]:
    top_committer = commit.get("committer") or {}
    raw_commit = commit.get("commit") or {}
    raw_committer = raw_commit.get("committer") or {}
    raw_author = raw_commit.get("author") or {}

    login = top_committer.get("login")
    email = raw_committer.get("email") or raw_author.get("email")
    name = top_committer.get("login") or raw_committer.get("name") or raw_author.get("name") or email or "unknown"

    if login:
        key = f"login:{login.lower()}"
    elif email:
        key = f"email:{email.lower()}"
    elif name:
        key = f"name:{name.lower()}"
    else:
        sha = commit.get("sha", "unknown")
        key = f"sha:{sha}"

    return (
        key,
        name,
        raw_committer.get("name") or raw_author.get("name"),
        email,
        raw_committer.get("date"),
        raw_author.get("date"),
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


def store_repository(connection: sqlite3.Connection, reference: str, token: Optional[str]) -> bool:
    commit_counts: DefaultDict[str, int] = defaultdict(int)
    committer_names = {}
    commit_total = 0

    try:
        owner, repo = normalize_repository(reference)
        full_name = f"{owner}/{repo}"

        print(f"Collecting {full_name}...")

        with connection:
            record_repository_status(connection, full_name, "collecting", None, 0, 0)
            connection.execute("DELETE FROM commits WHERE repo_full_name = ?", (full_name,))
            connection.execute("DELETE FROM committer_counts WHERE repo_full_name = ?", (full_name,))

            for commit in fetch_commits(owner, repo, token):
                sha = commit.get("sha")
                if not sha:
                    continue

                committer_key, committer_name, author_name, author_email, committed_at, authored_at = extract_committer_info(commit)
                message = (commit.get("commit") or {}).get("message")
                url = commit.get("html_url")

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
                        committer_key,
                        committer_name,
                        author_name,
                        author_email,
                        committed_at,
                        authored_at,
                        message,
                        url,
                    ),
                )

                commit_counts[committer_key] += 1
                committer_names[committer_key] = committer_name
                commit_total += 1

            for committer_key, count in commit_counts.items():
                connection.execute(
                    """
                    INSERT OR REPLACE INTO committer_counts (
                        repo_full_name, committer_key, committer_name, commit_count
                    ) VALUES (?, ?, ?, ?)
                    """,
                    (full_name, committer_key, committer_names[committer_key], count),
                )

            record_repository_status(
                connection,
                full_name,
                "success",
                None,
                commit_total,
                len(commit_counts),
            )
        print(f"Stored {commit_total} commits for {full_name}.")
        return True
    except (GitHubRepositoryError, sqlite3.Error, OSError, ValueError) as error:
        full_name = reference.strip() or reference
        print(f"Failed to collect {full_name}: {error}")
        try:
            with connection:
                record_repository_status(connection, full_name, "error", str(error), 0, 0)
        except sqlite3.Error as status_error:
            print(f"Failed to record status for {full_name}: {status_error}")
        return False


def main() -> int:
    args = parse_args()
    if args.repos:
        repositories = list(args.repos)
    elif args.repos_file:
        try:
            repositories = load_repositories_from_file(args.repos_file)
        except FileNotFoundError as error:
            print(error)
            return 1
    else:
        print("You must provide repositories with --repos-file or as positional arguments.")
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
        for reference in repositories:
            if store_repository(connection, reference, args.token):
                success_count += 1
            else:
                failure_count += 1
    finally:
        connection.close()

    report_script = Path(__file__).with_name("visualize_github_commit_history.py")
    report_path = Path(args.report_output)
    try:
        subprocess.run(
            [
                sys.executable,
                str(report_script),
                "--db",
                args.db,
                "--output",
                args.report_output,
            ],
            check=True,
        )
        webbrowser.open(report_path.resolve().as_uri())
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