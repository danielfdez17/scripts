#!/bin/bash

# ? Utils
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
INFO=$BLUE'[INFO]'
TODO=$ORANGE'[TODO]'
# OK=$GREEN'[OK]'
# ERROR=$RED'[ERROR]'
# WARNING=$YELLOW'[WARNING]'

OK="$GREEN🗸"
ERROR="$RED✗"
WARNING="$YELLOW⚠"

print_info()
{
	echo -e $INFO "$1" $NC
}

print_ok()
{
	echo -e $OK "$1" $NC
}

print_error()
{
	echo -e $ERROR "$1" $NC
}

print_warning()
{
	echo -e $WARNING "$1" $NC
}

print_todo()
{
	echo -e $TODO "$1" $NC
}
