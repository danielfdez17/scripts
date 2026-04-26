#!/bin/bash

make bonus

if [ -z "$1" ]; then
	print_warning "Usage: $0 <numbers>"
	print_warning "Run:"
	echo 'bash ./vendor/scripts/42/push_swap/single_test.sh $(max=100;seq -"$max" "$max" | shuf | head -n "$max" | tr "\n" " ")'
	# print_info "Example: $0 \"3 2 1\""
	exit 1
fi


ARG=$1; ./push_swap "$ARG" | ./checker "$ARG"