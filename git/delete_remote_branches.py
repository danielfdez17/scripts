#!/usr/bin/env python3

"""
This script is designed to delete specified Git branches from the remote repository.
"""

if __name__ == "__main__":
    import subprocess
    import sys

    if len(sys.argv) < 2:
        print("Usage: delete_remote_branches.py <branch1> [<branch2> ...]")
        sys.exit(1)

    branches = sys.argv[1:]

    for branch in branches:
        subprocess.run(["git", "push", "origin", "--delete", branch], check=True)
