#!/bin/bash

# ? Utils
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color
WARNING=$YELLOW'[WARNING]'
INFO=$BLUE'[INFO]'
OK=$GREEN'[OK]'
ERROR=$RED'[ERROR]'
TODO=$ORANGE'[TODO]'

log_info() {
	echo $INFO "$1" $NC
}

log_ok() {
	echo $OK "$1" $NC
}

log_error() {
	echo $ERROR "$1" $NC
}

log_warning() {
	echo $WARNING "$1" $NC
}

log_todo() {
	echo $TODO "$1" $NC
}

make bonus

if [ -z "$1" ]; then
	log_warning "Usage: $0 <numbers>"
	log_info "Example: $0 \"3 2 1\""
	exit 1
fi

ARG=$1; ./push_swap $ARG | ./checker $ARG