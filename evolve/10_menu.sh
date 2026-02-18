#!/bin/bash

while true
do
	echo "1) See current date"
	echo "2) See current working directory"
	echo "3) Exit"
	read -rp "Enter an option: " opt
	if [ $opt -eq 1 ]; then
		date
	elif [ $opt -eq 2 ]; then
		pwd
	elif [ $opt -eq 3 ]; then
		echo "Exiting the program..."
		exit 0
	else
		echo "$opt is not a valid option"
	fi
done
