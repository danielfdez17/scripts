#!/bin/bash

route="${1:-}"

if [ -z "$route" ]; then
	echo "Missing route :("
	exit 1
fi

if [ -d "$route" ]; then
	echo "Looking for txt files inside $route"
	find $route -name *.txt
	exit 0
else
	echo "Route does not exist :("
	exit 1
fi
