#!/usr/bin/bash

. "$(dirname "$0")/utils.sh"

if [ ! "$1" ]; then
	print_error "This script should receive at least one GitHub repository name as argument"
	exit 1
fi

print_info "Updating license file in all repositories..."
for repo in "$@"; do
	# Check if repository exists
	print_info "Checking if repository '$repo' exists..."
	if ! timeout 10 git ls-remote https://github.com/danielfdez17/"$repo".git &>/dev/null; then
		print_error "Repository '$repo' does not exist or is not accessible"
		continue
	fi
	
	print_info "Cloning repository '$repo'..."
	git clone git@github.com:danielfdez17/"$repo".git
	if [ ! -d "$repo" ]; then
		print_error "Failed to clone repository '$repo'"
		continue
	fi
	cd "$repo" || { print_error "Failed to enter repository '$repo'"; continue; }
	# replace Copyright year in LICENSE file
	# ! this should search for every past year and replace it with the current year, but for simplicity it will just replace 2025 with the current year
	sed -i "s/2025/$(date +%Y)/g" LICENSE
	git add . && git commit -m "docs: update license year" && git push
	cd ..
	rm -rf "$repo"
done
