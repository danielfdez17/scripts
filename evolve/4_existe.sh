#!/bin/bash

archivo="${1:-}"

if [ -z "$archivo" ]; then
	echo "No hay archivo como argumento :("
	exit 1
fi

if [ -f "$archivo" ]; then
	echo "Visualizando archivo..."
	cat $archivo
	echo "Saliendo del script..."
	exit 0
else
	echo "No existe el archivo :("
	exit 1
fi
