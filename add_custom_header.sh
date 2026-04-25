#!/bin/bash

. "$(dirname "$0")/utils/colors.sh"

set -e # Exit immediately if a command exits with a non-zero status, and treat unset variables as an error when substituting.

# This script is used to create a default header to files

header_file_target=header.template
if [ ! -f "$header_file_target" ]; then
	touch "$header_file_target"
	print_info "Header template created at $header_file_target. Customize it as needed."
fi

print_ok "Header template is ready at $header_file_target. You can now customize it with your desired header content."

if [ ! -s "$header_file_target" ]; then
	print_warning "Header template '$header_file_target' is empty. Please add header content before running this script."
	exit 1
fi

if [ -z "$1" ]; then
	print_warning "No target file provided. Please specify a file to which the header should be added."
	exit 1
fi

for target_file in "$@"; do
	if [ ! -f "$target_file" ]; then
		print_error "Target file '$target_file' does not exist. Skipping."
		continue
	fi

	header_content="$(cat "$header_file_target")"
	target_content="$(cat "$target_file")"

	if [[ "$target_content" == *"$header_content"* ]]; then
		print_info "Header already exists in '$target_file'. Skipping."
		continue
	fi

	target_file_copy="${target_file}.bak"
	cp "$target_file" "$target_file_copy"
	cat "$header_file_target" "$target_file_copy" > "$target_file"
	rm "$target_file_copy"
	print_ok "Header added to '$target_file'."
done