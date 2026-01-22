#!/bin/bash

dir="${1:-}"

if [ -z $dir ]; then
	echo "No folder destination has been provided :("
	exit 1
fi

if [ -d $dir ]; then
	for i in 1 2 3 4 5
	do
		touch "$dir/file$i.txt"
	done
	echo "Files created"
	exit 0
else
	echo "$dir is not a directory :("
	exit 1
fi
