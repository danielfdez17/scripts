#!/bin/bash

if [ ! "$1" ]; then
	echo "This script should receive at least on GitHub repository name as argument"
	exit 1
fi

echo "Updating license file in all repositories..."
for repo in "$@"; do
	# Check if repository exists
	echo "Checking if repository '$repo' exists..."
	if ! timeout 10 git ls-remote https://github.com/danielfdez17/"$repo".git &>/dev/null; then
		echo "Repository '$repo' does not exist or is not accessible"
		continue
	fi
	
	echo "Cloning repository '$repo'..."
	git clone git@github.com:danielfdez17/"$repo".git
	if [ ! -d "$repo" ]; then
		echo "Failed to clone repository '$repo'"
		continue
	fi
	cd "$repo"
	# replace Copyright year in LICENSE file
	sed -i "s/2025/$(date +%Y)/g" LICENSE
	git add . && git commit -m "update license year" && git push
	cd ..
	rm -rf "$repo"
done
