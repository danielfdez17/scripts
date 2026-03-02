#!/bin/sh

# This script is used to test the functionality of the project.
# It runs a series of tests and outputs the results.

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

clear
log_warning "Make sure ./push_swap is up to date"

generate_numbers() {
	if [ -z "$1" ]; then
		max=100
	else
		max=$1
	fi
	shuf -i 1-$max -n $max | tr "\n" " "
}

push_swap() {
	numbers=$(generate_numbers $1)
	echo -n $numbers " "
	# log_info "Testing with $1 numbers..."
	movs=$(echo $numbers | xargs ./push_swap | wc -l)
	# log_ok "Number of moves: $movs"
	return $movs
}

test_n() {
	n=$1
	limit=$2
	ok_iterations=0
	bad_iterations=0
	log_info "Running $iterations iterations with $n numbers..."
	for i in $(seq 1 $iterations); do
		numbers=$(push_swap $n)
		moves=$?
		# Check if the number of moves is greater than 12
		if [ $moves -gt $limit ]; then
			log_error "$numbers $moves moves (exceeds $limit)"
			bad_iterations=$((bad_iterations + 1))
		else
			log_ok "$moves moves (within $limit)"
			ok_iterations=$((ok_iterations + 1))
		fi
	done
	log_info "Summary for $n numbers: $GREEN$ok_iterations OK$NC, $RED$bad_iterations KO$BLUE out of $total_iterations iterations."
}

start() {
	# Check if at least 2 integer arguments were provided
	if [ $n -le 6 ]; then
		test_n $n 12
	elif [ $n -le 100 ]; then
		test_n $n 700
	elif [ $n -le 500 ]; then
		test_n $n 5500
	else
		test_n $n $n
	fi
}

# Check if ./push_swap exists
if [ ! -f "./push_swap" ]; then
	log_error "Error: ./push_swap not found. Please compile the project first."
	exit 1
fi

# Check if the first argument is provided, if not set it to 100
if [ -z $1 ]; then
	iterations=100
else
	iterations=$1
fi

# Check if the second argument is provided, if not set it to 100
if [ -z $2 ]; then
	n=100
else
	n=$2
fi

log_info "Starting tests with $iterations iterations and $n numbers..."
start