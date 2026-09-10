#!/usr/bin/env python3

"""
This script deletes all local git branches except 'main' and 'develop'.
Use with caution, as this will permanently delete branches that have not been merged.
"""

if __name__ == "__main__":
    import subprocess
    import sys

    branches = subprocess.check_output(["git", "branch"], text=True).splitlines()
    for branch in branches:
        branch = branch.strip()
    branches = [branch.strip() for branch in branches
            if branch.strip() and not branch.startswith("*")]
    print("The following branches will be deleted:")
    all_local = []
    for branch in branches:
        if branch not in ["main", "develop"]:
            print(f"'{branch}'")
            all_local.append(branch)

    confirm = input("Are you sure? (y/N): ")
    if confirm.lower() != "y":
        print("Operation cancelled.")
        sys.exit(1)

    for branch in all_local:
        subprocess.run(["git", "branch", "-D", branch], check=True)

    print("All local branches except 'main' and 'develop' have been deleted.")
