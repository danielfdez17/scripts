#!/bin/bash

if [ ! "$1" ]; then
	error_msg="This script should receive at least one GitHub repository name as argument"
	print_error "$error_msg" || echo "$error_msg"
	exit 1
fi

updating_license_msg="Updating license file in all repositories..."
print_info "$updating_license_msg" || echo "$updating_license_msg"
for repo in "$@"; do
	# Check if repository exists
	checking_repo_msg="Checking if repository '$repo' exists..."
	print_info "$checking_repo_msg" || echo "$checking_repo_msg"
	if ! timeout 10 git ls-remote https://github.com/danielfdez17/"$repo".git &>/dev/null; then
		not_found_msg="Repository '$repo' does not exist or is not accessible"
		print_error "$not_found_msg" || echo "$not_found_msg"
		continue
	fi
	
	cloining_repo_msg="Cloning repository '$repo'..."
	print_info "$cloining_repo_msg" || echo "$cloining_repo_msg"
	git clone git@github.com:danielfdez17/"$repo".git
	if [ ! -d "$repo" ]; then
		error_cloning_msg="Failed to clone repository '$repo'"
		print_error "$error_cloning_msg" || echo "$error_cloning_msg"
		continue
	fi
	error_entering_msg="Failed to enter repository '$repo'"
	cd "$repo" || { print_error "$error_entering_msg" || echo "$error_entering_msg"; continue; }
	# replace Copyright year in LICENSE file
	# ! this should search for every past year and replace it with the current year, but for simplicity it will just replace 2025 with the current year
	sed -i "s/2025/$(date +%Y)/g" LICENSE
	git add . && git commit -m "docs: update license year" && git push
	cd ..
	rm -rf "$repo"
done
