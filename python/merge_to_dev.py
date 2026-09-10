#!/usr/bin/env python3

"""
This script is designed to automate the process of merging the current Git branch into the develop
 branch and then deleting the current branch from the remote repository.
It performs the following steps:
1. Checks the current Git branch.
2. If the current branch is not develop, it switches to the develop branch.
3. Deletes the current branch from the remote repository.
4. Merges the current branch into develop.
5. Pushes the changes to the remote develop branch.
6. Provides error handling for each step to ensure that the process is smooth and any
 issues are clearly communicated to the user.
"""

if __name__ == "__main__":
    import subprocess
    import sys

    current_branch = subprocess.run(["git", "branch", "--show-current"],
        capture_output=True, text=True, check=True).stdout.strip()

    if current_branch == "develop":
        print("Already on develop branch.")
        sys.exit(0)

    print(f"""
        The current branch is: {current_branch},
        which will be merged into develop and then deleted from remote.
    """)

    print("\nSwithching to develop branch...")
    try:
        subprocess.run(["git", "checkout", "develop"], check=True)
    except subprocess.CalledProcessError:
        print("""
            Failed to switch to develop branch. 
            Please ensure it exists and you have permissions.
        """)
        sys.exit(1)

    # There is no need to exit the program execution as the branch to be merged
    # could exist only locally and not remotely, so we will attempt to
    # delete the remote branch and if it fails, we will continue with the merge process.
    print(f"\nDeleting remote branch {current_branch}...")
    try:
        subprocess.run(["git", "push", "origin", "--delete", current_branch], check=True)
    except subprocess.CalledProcessError:
        print(f"""
            Failed to delete remote branch {current_branch}.
            It may not exist or you may not have permission.
        """)

    print(f"\nMerging {current_branch} into develop...")
    try:
        subprocess.run(["git", "merge", current_branch], check=True)
    except subprocess.CalledProcessError:
        print(f"""
            Failed to merge {current_branch} into develop.
            Please resolve any conflicts and try again.
        """)
        sys.exit(1)

    print("Pushing changes to remote develop branch...")
    try:
        subprocess.run(["git", "push", "-u", "origin", "develop"], check=True)
    except subprocess.CalledProcessError:
        print("""
            Failed to push changes to remote develop branch.
            Please check your network connection and permissions.
        """)
        sys.exit(1)

    print(f"\nBranch {current_branch} has been merged into develop and deleted from remote.")
