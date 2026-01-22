#!/bin/bash

file="${1:-}"

if [ -z $file ]; then
	echo "Missing input file :("
	exit 1
fi

if [ -f $file ]; then
	read -rp "Enter a word to search in the file $file : " word
	count=$(cat $file | grep $word | wc -w)
	echo "'$word' appears $count times in '$file'"
	exit 0
else
	echo "That is not a file..."
	exit 1
fi
