#!/usr/bin/bash

# Time a command and, on success, print a message with the elapsed milliseconds.
#
# Usage:
#   run_and_log.sh MESSAGE -- COMMAND [ARG...]
#   run_and_log.sh -m MESSAGE -c SHELL_COMMAND
#
# MESSAGE may contain backslash escapes (for example \033[0;32m); they are
# printed with printf %b. An empty message is allowed.
# The script exits with the command's status. On failure the message is omitted.
# SHELL_COMMAND runs under bash -e, so a failing command stops the snippet.

set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  run_and_log.sh MESSAGE -- COMMAND [ARG...]
  run_and_log.sh -m MESSAGE -c SHELL_COMMAND

Run COMMAND and, if it exits 0, print MESSAGE and the elapsed milliseconds.
Backslash escapes in MESSAGE are interpreted. On failure, MESSAGE is not
printed and the script exits with COMMAND's status.
EOF
}

die() {
	echo "run_and_log.sh: $1" >&2
	usage >&2
	exit 2
}

now_ms() {
	local now secs frac

	if [[ -n ${EPOCHREALTIME-} ]]; then
		now=$EPOCHREALTIME
		secs=${now%%.*}
		frac=${now#*.}000
		printf '%d\n' "$((secs * 1000 + 10#${frac:0:3}))"
		return
	fi
	date +%s%3N
}

message=
shell_command=
mode=exec

if [[ $# -eq 0 ]]; then
	usage >&2
	exit 2
fi

if [[ $1 == -h || $1 == --help ]]; then
	usage
	exit 0
fi

if [[ $1 == -m || $1 == --message || $1 == -c || $1 == --command ]]; then
	while [[ $# -gt 0 ]]; do
		case $1 in
		-m | --message)
			[[ $# -ge 2 ]] || die "option $1 requires a message"
			message=$2
			shift 2
			;;
		-c | --command)
			[[ $# -ge 2 ]] || die "option $1 requires a shell command"
			shell_command=$2
			mode=shell
			shift 2
			;;
		--)
			shift
			break
			;;
		-*)
			die "unknown option: $1"
			;;
		*)
			break
			;;
		esac
	done
else
	message=$1
	shift
	if [[ ${1-} == -- ]]; then
		shift
	fi
fi

if [[ $mode == shell && $# -gt 0 ]]; then
	die "do not combine -c with extra arguments"
fi

if [[ $mode == shell && -z $shell_command ]]; then
	die "shell command is empty"
fi

if [[ $mode == exec && $# -eq 0 ]]; then
	die "missing command"
fi

start_ms=$(now_ms)
set +e
if [[ $mode == shell ]]; then
	bash -ec "$shell_command"
else
	"$@"
fi
status=$?
set -e
end_ms=$(now_ms)

if [[ $status -eq 0 ]]; then
	printf '%b [%sms]\n' "$message" "$((end_ms - start_ms))"
fi

exit "$status"
