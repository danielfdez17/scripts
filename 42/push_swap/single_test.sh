#!/bin/bash

# make bonus

if [ -z "$1" ]; then
	usage="Usage: $0 <numbers>"
	print_warning "$usage" || echo "$usage"
	tip="Run the commented line to randomize the input:"
	print_warning "$tip" || echo "$tip"
	# bash ./vendor/scripts/42/push_swap/single_test.sh $(max=100;seq -"$max" "$max" | shuf | head -n "$max" | tr "\n" " ")
	example="Example: $0 \"3 2 1\""
	print_info "$example" || echo "$example"
	exit 1
fi


ARG=$1; ./push_swap "$ARG" | ./checker "$ARG"