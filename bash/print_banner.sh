#!/usr/bin/bash

# Print a centered message inside a blue box-drawing banner.
# Usage: print_banner.sh "Your message"

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <message>" >&2
    exit 1
fi

BLUE=$'\033[0;34m'
RESET=$'\033[0m'

TOP_LEFT_CORNER="${BLUE}╭${RESET}"
TOP_RIGHT_CORNER="${BLUE}╮${RESET}"
BOTTOM_LEFT_CORNER="${BLUE}╰${RESET}"
BOTTOM_RIGHT_CORNER="${BLUE}╯${RESET}"
HORIZONTAL_LINE="${BLUE}━${RESET}"
VERTICAL_LINE="${BLUE}┃${RESET}"

message="$*"
message_length=${#message}
side_padding=2
inner_width=$((message_length + side_padding * 2))
left_padding=$side_padding
right_padding=$side_padding

top_border="$TOP_LEFT_CORNER"
bottom_border="$BOTTOM_LEFT_CORNER"
for ((i = 0; i < inner_width; i++)); do
    top_border+="$HORIZONTAL_LINE"
    bottom_border+="$HORIZONTAL_LINE"
done
top_border+="$TOP_RIGHT_CORNER"
bottom_border+="$BOTTOM_RIGHT_CORNER"

printf "%s\n" "$top_border"
printf "%s%*s%s%*s%s\n" \
    "$VERTICAL_LINE" \
    "$left_padding" '' \
    "$message" \
    "$right_padding" '' \
    "$VERTICAL_LINE"
printf "%s\n" "$bottom_border"
