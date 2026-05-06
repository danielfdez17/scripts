#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status, and treat unset variables as an error when substituting.

# This script is used to create a default header to files

header_file_target=header.template
if [ ! -f "$header_file_target" ]; then
	touch "$header_file_target"
	template_created_msg="Header template created at $header_file_target. Customize it as needed."
	print_info "$template_created_msg" || echo "$template_created_msg"
fi

template_exists_msg="Header template is ready at $header_file_target. You can now customize it with your desired header content."
print_ok "$template_exists_msg" || echo "$template_exists_msg"

if [ ! -s "$header_file_target" ]; then
	empty_template_msg="Header template '$header_file_target' is empty. Please add header content before running this script."
	print_warning "$empty_template_msg" || echo "$empty_template_msg"
	exit 1
fi

if [ -z "$1" ]; then
	no_target_file_msg="No target file provided. Please specify a file to which the header should be added."
	print_warning "$no_target_file_msg" || echo "$no_target_file_msg"
	exit 1
fi

for target_file in "$@"; do
	if [ ! -f "$target_file" ]; then
		non_existent_file_msg="Target file '$target_file' does not exist. Skipping."
		print_error "$non_existent_file_msg" || echo "$non_existent_file_msg"
		continue
	fi

	header_content="$(cat "$header_file_target")"
	target_content="$(cat "$target_file")"

	if [[ "$target_content" == *"$header_content"* ]]; then
		existing_header_msg="Header already exists in '$target_file'. Skipping."
		print_info "$existing_header_msg" || echo "$existing_header_msg"
		continue
	fi

	target_file_copy="${target_file}.bak"
	cp "$target_file" "$target_file_copy"
	cat "$header_file_target" "$target_file_copy" > "$target_file"
	rm "$target_file_copy"
	success_msg="Header added to '$target_file'."
	print_ok "$success_msg" || echo "$success_msg"
done