#!/bin/bash

# ? Utils
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
INFO=$YELLOW'[INFO]'
OK=$GREEN'[OK]'
ERROR=$RED'[ERROR]'

print_info()
{
	echo $INFO "$1" $NC
}

print_ok()
{
	echo $OK "$1" $NC
}

print_error()
{
	echo $ERROR "$1" $NC
}
