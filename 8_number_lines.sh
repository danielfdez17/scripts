#!/bin/bash

file="${1:-}"

if [ -z $file ]; then
	echo "Missing file :("
	exit 1
fi

if [ -f $file ]; then
	echo "Numbering lines of file $file..."
	i=1
	while IFS= read -r line
	do
		printf '%d: %s\n' "$i" "$line"
		i=$((i+1))
	done < $file
	exit 0
else
	echo "That is not a file, be carefull"
	exit 1
fi
