#!/usr/bin/env python3

"""
Sort a JSON file's object keys alphabetically and write the result back.
Nested objects are sorted as well. Array order is left unchanged.
"""

import json
import sys
from pathlib import Path


def _indent_unit(text):
    """Return the indent already used in the file, or a tab when none is found."""
    for line in text.splitlines():
        stripped = line.lstrip(" \t")
        if stripped and stripped != line:
            return line[:len(line) - len(stripped)]
    return "\t"


def sort_json(file_path):
    """Load a JSON file, sort its object keys, and overwrite the file."""
    path = Path(file_path)
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    rendered = json.dumps(
        data,
        indent=_indent_unit(text),
        sort_keys=True,
        ensure_ascii=False,
    )
    path.write_text(rendered + "\n", encoding="utf-8")
    return data


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} <file.json>", file=sys.stderr)
        sys.exit(1)

    target = sys.argv[1]
    try:
        sort_json(target)
    except FileNotFoundError:
        print(f"File not found: {target}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as error:
        print(f"Invalid JSON in {target}: {error}", file=sys.stderr)
        sys.exit(1)
