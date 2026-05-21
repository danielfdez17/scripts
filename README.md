# Scripts

## What the project contains
- Scripts to automate boring, repetitive tasks
- Configuration files to avoid recreating them

## Git commit history
- [git/store_github_commit_history.py](git/store_github_commit_history.py) collects commit history from one or more local Git repositories and stores both the raw commits and per-committer counts in a SQLite database.
- [git/visualize_github_commit_history.py](git/visualize_github_commit_history.py) turns that SQLite database into a browser-friendly HTML report with per-repository commit charts.

Example:

```bash
cat > github_repositories.txt <<'EOF'
/home/daniel/projects/repos/owner-repo
/home/daniel/projects/repos/another-repo
EOF

python3 git/store_github_commit_history.py --repos-file github_repositories.txt --db commits.sqlite3
python3 git/visualize_github_commit_history.py --db commits.sqlite3 --output commits-report.html
```

The collector also runs the HTML report generator and opens the report in your browser after it finishes.
