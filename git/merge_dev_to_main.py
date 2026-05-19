#!/usr/bin/env python3

"""
This script is designed to automate the process of merging the develop branch into the main branch.
"""

if __name__ == "__main__":
    import subprocess
    import sys

    current_branch = subprocess.run(["git", "branch", "--show-current"],
        capture_output=True, text=True, check=True).stdout.strip()

    if current_branch != "main":
        print("Switching to main branch first...")

    print("""
        Merging develop branch into main branch...
    """)

    try:
        subprocess.run(["git", "switch", "main"], check=True)
    except subprocess.CalledProcessError:
        print("""
            Failed to switch to main branch. 
            Please ensure it exists and you have permissions.
        """)
        sys.exit(1)

    print("\nMerging develop into main...")
    try:
        subprocess.run(["git", "merge", "develop"], check=True)
    except subprocess.CalledProcessError:
        print("""
            Failed to merge develop into main.
            Please resolve any conflicts and try again.
        """)
    print("\n Pushing changes to remote main branch...")
    try:
        subprocess.run(["git", "push", "-u", "origin", "main"], check=True)
    except subprocess.CalledProcessError:
        print("""
            Failed to push changes to remote main branch.
            Please resolve any conflicts and try again.
        """)
