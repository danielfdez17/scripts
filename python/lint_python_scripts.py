#!/usr/bin/env python3

"""
This script is designed to lint all Python scripts in the current directory and
 its subdirectories using pylint.
"""

GREEN = "\033[0;32m"
RED = "\033[0;31m"
INFO = "\033[0;34m"
RESET = "\033[0m"

if __name__ == "__main__":
    from pathlib import Path
    import subprocess

    summary = {"successful": 0, "failed": 0}

    for path in Path('.').rglob('*.py'):
        print(path.name)
        try:
            print(f"{INFO}Linting {path}...")
            result = subprocess.run(['pylint', str(path)], check=True)
            if result.returncode == 0:
                summary["successful"] += 1
            else:
                summary["failed"] += 1
        except subprocess.CalledProcessError:
            summary["failed"] += 1
        print(f"{RESET}")

    print(f"""
    Linting completed.
    {GREEN}Successful: {summary['successful']}{RESET}
    {RED}Failed: {summary['failed']}{RESET}
    """)
