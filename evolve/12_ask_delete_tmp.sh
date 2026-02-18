#!/bin/bash

dir="${1:-}"

if [ -z $dir ]; then
	echo "The script needs a directory"
	exit 1
fi

if [ -d $dir ]; then
	read -rp "Are you sure you want to remove every .tmp file inside '$dir' ? [y/n] " ans
	if [ $ans = "y" ]; then
		echo "Deleting .tmp file inside '$dir'..."
		rm -rf "$dir/*.tmp"
	elif [ $ans = "n" ]; then
		echo "Seems you have reconsider your choice, well done"
	else
		echo "'$ans' it is not a valid answer"
	fi
	exit 0
else
	echo "'$dir' is not a directory"
	exit 1
fi
