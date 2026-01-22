#!/bin/bash

dir="${1:-}"

if [ ! -d "$dir" ]; then
	echo "No es un directorio"
	exit 1
fi

count=$(ls -l $dir | wc -l)

echo "Archivos encontrados en $dir: $count"
