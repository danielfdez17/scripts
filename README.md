# Scripts

## What the project contains
- Scripts to automate boring, repetitive tasks
- Configuration files to avoid recreating them

## GitHub commit history
- [git/store_github_commit_history.py](git/store_github_commit_history.py) collects commit history for one or more GitHub repositories and stores both the raw commits and per-committer counts in a SQLite database.
- [git/visualize_github_commit_history.py](git/visualize_github_commit_history.py) turns that SQLite database into a browser-friendly HTML report with per-repository commit charts.

Example:

```bash
python3 git/store_github_commit_history.py --db commits.sqlite3 owner/repo another-owner/another-repo
python3 git/visualize_github_commit_history.py --db commits.sqlite3 --output commits-report.html
```

Set `GITHUB_TOKEN` or pass `--token` when you need access to private repositories.
