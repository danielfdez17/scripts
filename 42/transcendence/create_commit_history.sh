#!/bin/bash

cd 42/transcendence

rm -rf commits.sqlite3

python3 store_github_commit_history.py --repos-file transcendence_local.txt --db commits.sqlite3