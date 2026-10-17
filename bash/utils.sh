#!/usr/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=print_error.sh
. "${script_dir}/print_error.sh"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=print_info.sh
. "${script_dir}/print_info.sh"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=print_success.sh
. "${script_dir}/print_success.sh"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=print_warning.sh
. "${script_dir}/print_warning.sh"
