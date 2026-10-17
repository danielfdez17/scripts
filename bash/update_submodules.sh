#!/usr/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=utils.sh
. "${script_dir}/utils.sh"

print_info "Updating submodules..."
git submodule update --init --recursive --remote

