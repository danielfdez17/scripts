#!/usr/bin/bash

dir="${1:-}"

if [ ! -d "$dir" ]; then
	echo "No es un directorio"
	exit 1
fi

count=$(find "$dir" -type f | wc -l)

echo "Archivos encontrados en $dir: $count"
