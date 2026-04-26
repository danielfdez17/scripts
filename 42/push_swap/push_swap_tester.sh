#!/bin/bash

# ! This script is used to test the functionality of the project.
# ! It runs a series of tests and outputs the results.

# ? Utils
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BLUE='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m' # ? No Color

# * Top row (╭━━━╮) - round corners, full-span
# * Bottom row (╰━━━╯) - round corners, full-span
# * Merge row (┣━━━┫) - full-span, left/right T junctions
# * Merge-bottom (╰━━━╯) - alias for kind 3
# * Column cross (┣━╋━┫) - cross junctions (columns above/below)
# * Column open (┣━┳━┫) - T-down (columns start below)
# * Column close (┣━┻━┫) - T-up (columns end above)

print_top_left_corner() {
	echo -en "$ORANGE╭$NC"
}

print_top_right_corner() {
	echo -e "$ORANGE╮$NC"
}

print_bottom_left_corner() {
	echo -en "$ORANGE╰$NC"
}

print_bottom_right_corner() {
	echo -e "$ORANGE╯$NC"
}

print_horizontal_line() {
	echo -en "$ORANGE━$NC"
}

print_vertical_line() {
	echo -en "$ORANGE┃$NC"
}

print_left_junction() {
	echo -en "$ORANGE┣$NC"
}

print_right_junction() {
	echo -en "$ORANGE┫$NC"
}

print_cross() {
	echo -en "$ORANGE╋$NC"
}

print_top_junction() {
	echo -en "$ORANGE┳$NC"
}

print_bottom_junction() {
	echo -en "$ORANGE┻$NC"
}

print_table_separator() {
	width=$1
	print_left_junction
	for i in $(seq 1 "$width"); do
		print_horizontal_line
	done
	print_right_junction
	echo
}

print_table_header_separator() {
	# For: #, Moves, Result, Numbers (with cross junctions)
	print_left_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_cross
	for i in $(seq 1 8); do print_horizontal_line; done
	print_cross
	for i in $(seq 1 8); do print_horizontal_line; done
	print_cross
	for i in $(seq 1 8); do print_horizontal_line; done
	print_cross
	for i in $(seq 1 43); do print_horizontal_line; done
	print_right_junction
	echo
}

print_table_top() {
	print_top_left_corner
	for i in $(seq 1 8); do print_horizontal_line; done
	print_top_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_top_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_top_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_top_junction
	for i in $(seq 1 43); do print_horizontal_line; done
	print_top_right_corner
}

print_table_bottom() {
	print_bottom_left_corner
	for i in $(seq 1 8); do print_horizontal_line; done
	print_bottom_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_bottom_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_bottom_junction
	for i in $(seq 1 8); do print_horizontal_line; done
	print_bottom_junction
	for i in $(seq 1 43); do print_horizontal_line; done
	print_bottom_right_corner
}

print_summary_top() {
	print_top_left_corner
	for i in $(seq 1 70); do print_horizontal_line; done
	print_top_right_corner
}

print_summary_bottom() {
	print_bottom_left_corner
	for i in $(seq 1 70); do print_horizontal_line; done
	print_bottom_right_corner
}

clear
print_info "Glyphs for table formatting thanks to Dylan (https://github.com/Univers42/picine_cpp/blob/main/cpp_module04/ex03/postman.cpp)"
print_warning "Make sure ./push_swap and ./checker are up to date"
# make bonus

if [ ! -f "./push_swap" ]; then
	print_error "Error: ./push_swap not found. Please compile the project first."
	exit 1
fi

if [ ! -f "./checker" ]; then
	print_error "Error: ./checker not found. Please compile the project first."
	exit 1
fi

generate_numbers() {
	if [ -z "$1" ]; then
		max=100
	else
		max=$1
	fi
	seq -"$max" "$max" | shuf | head -n "$max" | tr "\n" " "
	# shuf -i 1-"$max" -n "$max" | tr "\n" " "
}

test_n() {
	n=$1
	limit=$2
	ok_iterations=0
	bad_iterations=0
	ok_checker=0
	ko_checker=0
	total_moves=0
	max_moves=0
	min_moves=999999
	
	echo
	print_info "Running $iterations iterations with $n numbers..."
	total_time=0
	max_time=0
	min_time=999999999
	echo
	
	# Print table header
	print_table_top
	print_vertical_line
	printf " ${BLUE}%-6s${NC} " "#"
	print_vertical_line
	printf " ${BLUE}%-6s${NC} " "Moves"
	print_vertical_line
	printf " ${BLUE}%-6s${NC} " "Time"
	print_vertical_line
	printf " ${BLUE}%-6s${NC} " "Result"
	print_vertical_line
	printf " ${BLUE}%-41s${NC} " "Generated Numbers"
	print_vertical_line
	echo
	print_table_header_separator
	
	for i in $(seq 1 "$iterations"); do
		numbers=$(generate_numbers "$n")
		# Measure time for push_swap (and checker) using milliseconds
		start_ms=$(date +%s%3N)
		output=$(echo "$numbers" | xargs ./push_swap)
		moves=$(echo "$output" | wc -l)
		checker_result=$(echo "$output" | ./checker "$numbers")
		end_ms=$(date +%s%3N)
		elapsed_ms=$((end_ms - start_ms))
		time_formatted=$(awk "BEGIN {printf \"%.f\", $elapsed_ms}")
		time_formatted=$(printf "%2s%s" "$time_formatted" "ms")
		max_moves=$((moves > max_moves ? moves : max_moves))
		min_moves=$((moves < min_moves ? moves : min_moves))

		total_time=$((total_time + elapsed_ms))
		max_time=$((elapsed_ms > max_time ? elapsed_ms : max_time))
		min_time=$((elapsed_ms < min_time ? elapsed_ms : min_time))
		
		if [ "$checker_result" = "OK" ]; then
			status_color=$GREEN
			status_text="OK"
			ok_checker=$((ok_checker + 1))
		else
			status_color=$RED
			status_text="KO"
			ko_checker=$((ko_checker + 1))
		fi
		
		total_moves=$((total_moves + moves))
		
		# Truncate numbers if too long
		numbers_display=$(echo "$numbers" | cut -c1-38)
		if [ ${#numbers} -gt 38 ]; then
			numbers_display="${numbers_display}..."
		fi
		
		# Check if the number of moves is greater than the limit
		if [ "$moves" -gt "$limit" ]; then
			move_color=$RED
			bad_iterations=$((bad_iterations + 1))
		else
			move_color=$GREEN
			ok_iterations=$((ok_iterations + 1))
		fi
		
		# Pre-format the content with fixed width
		num_formatted=$(printf '%-6s' "$i")
		move_formatted=$(printf '%-6s' "$moves")
		status_formatted=$(printf '%-6s' "$status_text")
		time_formatted=$(printf '%-6s' "$time_formatted")
		numbers_formatted=$(printf '%-41s' "$numbers_display")
		
		print_vertical_line
		printf " %s " "$num_formatted"
		print_vertical_line
		printf " $move_color%s$NC " "$move_formatted"
		print_vertical_line
		printf " $BLUE%s$NC " "$time_formatted"
		print_vertical_line
		printf " $status_color%s$NC " "$status_formatted"
		print_vertical_line
		printf " $BLUE%s$NC " "$numbers_formatted"
		print_vertical_line
		echo
	done
	
	print_table_bottom
	echo
	
	# Calculate statistics
	percentage_ok=$(awk "BEGIN {printf \"%.2f\", ($ok_iterations/$iterations)*100}")
	percentage_ko=$(awk "BEGIN {printf \"%.2f\", ($bad_iterations/$iterations)*100}")
	checker_percentage_ok=$(awk "BEGIN {printf \"%.2f\", ($ok_checker/$iterations)*100}")
	checker_percentage_ko=$(awk "BEGIN {printf \"%.2f\", ($ko_checker/$iterations)*100}")
	avg_time=$(awk "BEGIN {printf \"%.2f\", $total_time/$iterations}")
	avg_moves=$(awk "BEGIN {printf \"%.2f\", $total_moves/$iterations}")
	
	# Print summary table
	print_summary_top
	print_vertical_line
	summary_title=$(printf '%-68s' "SUMMARY FOR $n NUMBERS IN $iterations ITERATIONS")
	printf " $BLUE%s$NC " "$summary_title"
	print_vertical_line
	echo
	print_table_separator 70
	print_vertical_line
	pushswap_title=$(printf '%-68s' "PUSH_SWAP RESULTS")
	printf " $YELLOW%s$NC " "$pushswap_title"
	print_vertical_line
	echo
	print_vertical_line
	success_line=$(printf '%-66s' "Success: $percentage_ok% ($ok_iterations/$iterations)")
	printf "   $GREEN%s$NC " "$success_line"
	print_vertical_line
	echo
	print_vertical_line
	failure_line=$(printf '%-66s' "Failure: $percentage_ko% ($bad_iterations/$iterations)")
	printf "   $RED%s$NC " "$failure_line"
	print_vertical_line
	echo
	print_table_separator 70
	print_vertical_line
	checker_title=$(printf '%-68s' "CHECKER RESULTS")
	printf " $YELLOW%s$NC " "$checker_title"
	print_vertical_line
	echo
	print_vertical_line
	ok_line=$(printf '%-66s' "OK: $checker_percentage_ok% ($ok_checker/$iterations)")
	printf "   $GREEN%s$NC " "$ok_line"
	print_vertical_line
	echo
	print_vertical_line
	ko_line=$(printf '%-66s' "KO: $checker_percentage_ko% ($ko_checker/$iterations)")
	printf "   $RED%s$NC " "$ko_line"
	print_vertical_line
	echo
	print_table_separator 70
	print_vertical_line
	stats_title=$(printf '%-68s' "STATISTICS")
	printf " $YELLOW%s$NC " "$stats_title"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Average moves: $avg_moves"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Average time: ${avg_time}ms (avg over $iterations iterations)"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Max time: ${max_time}ms"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Min time: ${min_time}ms"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Max moves: $max_moves (limit: $limit)"
	print_vertical_line
	echo
	print_vertical_line
	printf "   %-66s " "Min moves: $min_moves"
	print_vertical_line
	echo
	print_summary_bottom
	echo
}

start() {
	# ? Check if at least 2 integer arguments were provided
	if [ "$n" -le 5 ]; then
		test_n "$n" 12
	elif [ "$n" -le 100 ]; then
		test_n "$n" 700
	elif [ "$n" -le 500 ]; then
		test_n "$n" 5500
	else
		test_n "$n" "$n"
	fi
}

# ? Check if ./push_swap exists
if [ ! -f "./push_swap" ]; then
	print_error "Error: ./push_swap not found. Please compile the project first."
	exit 1
fi

# ? Check if the first argument is provided, if not set it to 100
if [ -z "$1" ]; then
	iterations=100
else
	iterations="$1"
fi

# ? Check if the second argument is provided, if not set it to 100
if [ -z "$2" ]; then
	n=100
else
	n="$2"
fi

start