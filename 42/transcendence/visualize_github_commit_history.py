#!/usr/bin/env python3

"""Render an HTML report for the GitHub commit history database.

The report summarizes each repository and embeds a simple SVG bar chart for the
top committers stored in the SQLite database created by
store_github_commit_history.py.
"""

import argparse
import html
import sqlite3
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional


DEFAULT_DB_PATH = "github_commit_history.sqlite3"
DEFAULT_OUTPUT_PATH = "github_commit_history_report.html"


@dataclass
class RepositorySummary:
    full_name: str
    last_status: str
    last_error: Optional[str]
    commit_total: int
    committer_total: int
    last_collected_at: str


@dataclass
class CommitterCount:
    committer_name: str
    commit_count: int


@dataclass
class GroupSummary:
  group_name: str
  commit_total: int
  repository_total: int
  members: List[str]


CONTRIBUTOR_GROUPS = {
  "vjan-nie": ["Vado", "vjan-nie"],
  "rstancu": ["settes"],
  "serjimen": ["serjimen", "DJSurgeon"],
  "dlesieur": ["LESdylan", "dlesieur"],
  "danfern3": ["danielfdez17"],
  "GitHub": ["GitHub"],
  "AI Assistant": ["AI Assistant"],
  "test": ["test"],
}

GROUP_BY_MEMBER = {
  member.lower(): group
  for group, members in CONTRIBUTOR_GROUPS.items()
  for member in members
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create an HTML visualization for a GitHub commit history SQLite database."
    )
    parser.add_argument(
        "--db",
        default=DEFAULT_DB_PATH,
        help=f"Path to the SQLite database file (default: {DEFAULT_DB_PATH}).",
    )
    parser.add_argument(
        "--output",
        default=DEFAULT_OUTPUT_PATH,
        help=f"Path to the HTML report to generate (default: {DEFAULT_OUTPUT_PATH}).",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=10,
        help="Number of committers to show per repository (default: 10).",
    )
    return parser.parse_args()


def load_repositories(connection: sqlite3.Connection) -> List[RepositorySummary]:
    rows = connection.execute(
        """
        SELECT full_name, last_status, COALESCE(last_error, ''), commit_total,
               committer_total, last_collected_at
        FROM repositories
        ORDER BY full_name
        """
    ).fetchall()

    return [
        RepositorySummary(
            full_name=row[0],
            last_status=row[1],
            last_error=row[2] or None,
            commit_total=row[3],
            committer_total=row[4],
            last_collected_at=row[5],
        )
        for row in rows
    ]


def load_committers(connection: sqlite3.Connection, repo_full_name: str, limit: int) -> List[CommitterCount]:
    rows = connection.execute(
        """
        SELECT committer_name, commit_count
        FROM committer_counts
        WHERE repo_full_name = ?
        ORDER BY commit_count DESC, committer_name ASC
        LIMIT ?
        """,
        (repo_full_name, limit),
    ).fetchall()

    return [CommitterCount(committer_name=row[0], commit_count=row[1]) for row in rows]


def load_contributor_rows(connection: sqlite3.Connection) -> List[tuple[str, str, str, int]]:
  return connection.execute(
    """
    SELECT committer_name, committer_email, repo_full_name, commit_count
    FROM committer_counts
    ORDER BY committer_name ASC
    """
  ).fetchall()


def group_contributors(rows: List[tuple[str, str, str, int]]) -> List[GroupSummary]:
  grouped: dict[str, dict[str, object]] = {}
  for committer_name, _committer_email, repo_full_name, commit_count in rows:
    group_name = GROUP_BY_MEMBER.get(committer_name.lower(), committer_name)
    entry = grouped.setdefault(
      group_name,
      {
        "commit_total": 0,
        "repos": set(),
        "members": set(),
      },
    )
    entry["commit_total"] += commit_count
    entry["repos"].add(repo_full_name)
    entry["members"].add(committer_name)

  summaries = [
    GroupSummary(
      group_name=group_name,
      commit_total=entry["commit_total"],
      repository_total=len(entry["repos"]),
      members=sorted(entry["members"]),
    )
    for group_name, entry in grouped.items()
  ]
  return sorted(summaries, key=lambda item: (-item.commit_total, item.group_name.lower()))


def load_schema(connection: sqlite3.Connection) -> None:
    tables = {
        row[0]
        for row in connection.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        ).fetchall()
    }
    required = {"repositories", "committer_counts"}
    missing = required - tables
    if missing:
        raise RuntimeError(f"Database is missing required tables: {', '.join(sorted(missing))}")


def status_badge(status: str) -> str:
    label = html.escape(status.title())
    return f'<span class="status status-{html.escape(status)}">{label}</span>'


def render_contributor_summary_card(connection: sqlite3.Connection) -> str:
  rows = load_contributor_rows(connection)
  groups = group_contributors(rows)
  total_contributors = len(groups)

  if not groups:
        contributor_items = '<li class="empty">No contributors were found in the database.</li>'
  else:
      contributor_items = "".join(
          """
          <li>
      <strong>{name}</strong>
      <span class="members">{members}</span>
      <span>{commits} commits across {repos} repositories</span>
          </li>
          """.format(
      name=html.escape(group.group_name),
      members=html.escape(", ".join(group.members)) if group.members else "",
      commits=group.commit_total,
      repos=group.repository_total,
          )
    for group in groups
      )

  return f"""
  <section class="summary-card">
    <div class="summary-header">
      <div>
        <p class="eyebrow">Contributors</p>
        <h2>Contributor Summary</h2>
      </div>
      <div class="summary-total">
        <span class="label">Unique contributors</span>
        <strong>{total_contributors}</strong>
      </div>
    </div>
    <ul class="contributor-list">
      {contributor_items}
    </ul>
  </section>
  """


def render_bar_chart(committers: List[CommitterCount]) -> str:
    if not committers:
        return '<p class="empty">No committer counts stored for this repository.</p>'

    max_count = max(committer.commit_count for committer in committers)
    row_height = 34
    chart_width = 720
    label_width = 280
    value_width = 90
    bar_width = chart_width - label_width - value_width - 40
    chart_height = 38 + (len(committers) * row_height)

    bars = []
    for index, committer in enumerate(committers):
        y = 30 + index * row_height
        width = 0 if max_count == 0 else int((committer.commit_count / max_count) * bar_width)
        bars.append(
            """
            <g>
              <text x="0" y="{y}" class="chart-label">{name}</text>
              <rect x="{bar_x}" y="{bar_y}" width="{width}" height="18" rx="9"></rect>
              <text x="{value_x}" y="{y}" class="chart-value">{count}</text>
            </g>
            """.format(
                y=y,
                name=html.escape(committer.committer_name),
                bar_x=label_width,
                bar_y=y - 15,
                width=width,
                value_x=label_width + bar_width + 24,
                count=committer.commit_count,
            )
        )

    return (
        f'<svg viewBox="0 0 {chart_width} {chart_height}" class="chart" role="img" aria-label="Commit counts per committer">'
        + "".join(bars)
        + "</svg>"
    )


def render_repository_section(connection: sqlite3.Connection, repo: RepositorySummary, top: int) -> str:
    committers = load_committers(connection, repo.full_name, top)
    error_html = ""
    if repo.last_error:
        error_html = f'<p class="error">{html.escape(repo.last_error)}</p>'

    return f"""
    <section class="repo-card">
      <header>
        <div>
          <h2>{html.escape(repo.full_name)}</h2>
          <p class="meta">Collected at {html.escape(repo.last_collected_at)}</p>
        </div>
        {status_badge(repo.last_status)}
      </header>
      <div class="stats">
        <div><span class="label">Commits</span><strong>{repo.commit_total}</strong></div>
        <div><span class="label">Committers</span><strong>{repo.committer_total}</strong></div>
      </div>
      {error_html}
      {render_bar_chart(committers)}
    </section>
    """


def render_html(
  repositories: List[RepositorySummary],
  connection: sqlite3.Connection,
  top: int,
  db_path: str,
) -> str:
    sections = "\n".join(render_repository_section(connection, repo, top) for repo in repositories)
    if not sections:
        sections = '<section class="repo-card"><p class="empty">No repositories were found in the database.</p></section>'

    total_commits = sum(repo.commit_total for repo in repositories)
    total_repositories = len(repositories)
    contributor_summary_card = render_contributor_summary_card(connection)

    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>GitHub Commit History Report</title>
  <style>
    :root {{
      color-scheme: light;
      --bg: #f5f1e8;
      --panel: #fffdf8;
      --ink: #1f2933;
      --muted: #65717e;
      --accent: #0f766e;
      --accent-soft: #d6f0ec;
      --warning: #b45309;
      --warning-soft: #fef3c7;
      --error: #b91c1c;
      --error-soft: #fee2e2;
      --border: #e6ddd0;
      --shadow: 0 20px 45px rgba(31, 41, 51, 0.08);
    }}
    body {{
      margin: 0;
      font-family: Georgia, "Times New Roman", serif;
      color: var(--ink);
      background: radial-gradient(circle at top, #fff8ea 0, var(--bg) 48%, #efe7db 100%);
    }}
    .page {{
      max-width: 1180px;
      margin: 0 auto;
      padding: 32px 20px 56px;
    }}
    .hero {{
      background: linear-gradient(135deg, #173f5f 0%, #0f766e 100%);
      color: white;
      border-radius: 24px;
      padding: 30px 32px;
      box-shadow: var(--shadow);
    }}
    .hero h1 {{
      margin: 0 0 10px;
      font-size: clamp(2rem, 4vw, 3.6rem);
      letter-spacing: -0.03em;
    }}
    .hero p {{
      margin: 0;
      max-width: 64ch;
      line-height: 1.6;
      color: rgba(255, 255, 255, 0.88);
    }}
    .summary-card {{
      margin: 18px 0 30px;
      padding: 22px 24px;
      background: linear-gradient(180deg, #ffffff 0%, #fffaf1 100%);
      border: 1px solid var(--border);
      border-radius: 22px;
      box-shadow: var(--shadow);
    }}
    .summary-header {{
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 16px;
      margin-bottom: 18px;
    }}
    .summary-header h2 {{
      margin: 0;
      font-size: 1.45rem;
    }}
    .eyebrow {{
      margin: 0 0 6px;
      color: var(--accent);
      font-size: 0.82rem;
      font-weight: 700;
      letter-spacing: 0.14em;
      text-transform: uppercase;
    }}
    .summary-total {{
      min-width: 160px;
      padding: 14px 16px;
      border-radius: 18px;
      background: var(--accent-soft);
      border: 1px solid rgba(15, 118, 110, 0.12);
      text-align: right;
    }}
    .summary-total .label {{
      display: block;
      color: var(--muted);
      font-size: 0.9rem;
    }}
    .summary-total strong {{
      display: block;
      margin-top: 6px;
      font-size: 1.8rem;
      color: var(--accent);
    }}
    .contributor-list {{
      margin: 0;
      padding: 0;
      list-style: none;
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 12px;
    }}
    .contributor-list li {{
      padding: 14px 16px;
      border-radius: 18px;
      background: #faf7f0;
      border: 1px solid var(--border);
      display: grid;
      gap: 4px;
    }}
    .contributor-list li strong {{
      font-size: 1rem;
    }}
    .contributor-list li span {{
      color: var(--muted);
      font-size: 0.93rem;
      line-height: 1.4;
    }}
    .contributor-list li .members {{
      display: block;
      font-size: 0.88rem;
      margin: 2px 0;
      color: var(--accent);
    }}
    .overview {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px;
      margin: 22px 0 30px;
    }}
    .overview .tile, .repo-card {{
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 22px;
      box-shadow: var(--shadow);
    }}
    .overview .tile {{
      padding: 18px 20px;
    }}
    .overview .tile .label, .stats .label, .meta {{
      color: var(--muted);
    }}
    .overview .tile strong, .stats strong {{
      display: block;
      font-size: 1.7rem;
      margin-top: 6px;
    }}
    .repo-card {{
      padding: 22px 24px 18px;
      margin-bottom: 18px;
    }}
    .repo-card header {{
      display: flex;
      gap: 14px;
      align-items: flex-start;
      justify-content: space-between;
      margin-bottom: 16px;
    }}
    .repo-card h2 {{
      margin: 0;
      font-size: 1.45rem;
    }}
    .meta {{
      margin: 6px 0 0;
      font-size: 0.95rem;
    }}
    .status {{
      display: inline-flex;
      align-items: center;
      padding: 8px 12px;
      border-radius: 999px;
      font-size: 0.9rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }}
    .status-success {{ background: var(--accent-soft); color: var(--accent); }}
    .status-error {{ background: var(--error-soft); color: var(--error); }}
    .stats {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 12px;
      margin-bottom: 14px;
    }}
    .stats div {{
      background: #faf7f0;
      border-radius: 18px;
      padding: 14px 16px;
      border: 1px solid var(--border);
    }}
    .chart {{
      width: 100%;
      height: auto;
      overflow: visible;
    }}
    .chart rect {{ fill: #0f766e; }}
    .chart-label {{
      fill: var(--ink);
      font-size: 14px;
      dominant-baseline: middle;
    }}
    .chart-value {{
      fill: var(--muted);
      font-size: 14px;
      dominant-baseline: middle;
      text-anchor: end;
    }}
    .empty, .error {{ margin: 0; line-height: 1.6; }}
    .error {{
      margin-bottom: 12px;
      padding: 12px 14px;
      border-radius: 14px;
      background: var(--error-soft);
      color: var(--error);
    }}
    .footer {{
      margin-top: 28px;
      color: var(--muted);
      font-size: 0.95rem;
    }}
    @media (max-width: 720px) {{
      .hero, .repo-card {{ padding-left: 18px; padding-right: 18px; }}
      .repo-card header {{ flex-direction: column; }}
      .status {{ align-self: flex-start; }}
    }}
  </style>
</head>
<body>
  <main class="page">
    <section class="hero">
      <h1>GitHub Commit History</h1>
      <p>This report visualizes the repository history stored in the SQLite database, with per-repository totals and a bar chart for the top committers.</p>
    </section>

    {contributor_summary_card}

    <section class="overview" aria-label="summary">
      <div class="tile"><span class="label">Repositories</span><strong>{total_repositories}</strong></div>
      <div class="tile"><span class="label">Total commits</span><strong>{total_commits}</strong></div>
      <div class="tile"><span class="label">Top committers shown</span><strong>{top}</strong></div>
    </section>

    {sections}

    <p class="footer">Generated from {html.escape(db_path)}. Re-run the collector before regenerating the report to refresh the numbers.</p>
  </main>
</body>
</html>
"""


def main() -> int:
  args = parse_args()
  db_path = Path(args.db)
  if not db_path.exists():
    print(f"Database not found: {db_path}")
    return 1

  connection = None
  try:
    connection = sqlite3.connect(str(db_path))
    load_schema(connection)
    repositories = load_repositories(connection)
    html_report = render_html(repositories, connection, args.top, str(db_path))
  except (sqlite3.Error, RuntimeError) as error:
    print(f"Failed to build report: {error}")
    return 1
  finally:
    if connection is not None:
      connection.close()

  output_path = Path(args.output)
  output_path.write_text(html_report, encoding="utf-8")
  print(f"Report written to {output_path}")
  return 0


if __name__ == "__main__":
    sys.exit(main())