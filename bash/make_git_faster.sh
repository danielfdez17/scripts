#!/usr/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=utils.sh
. "${script_dir}/utils.sh"

# Upgrade the index
print_info "Upgrading Git index..."
git config feature.manyFiles true

# Switches Git to a format built for large repos -- faster status, add, and commit.

# Stop scanning everything
print_info "Enabling fsmonitor to stop scanning everything..."
git config core.fsmonitor true

# OS watches the filesystem -- Git only checks files that actually changed.

# Background optimization
print_info "Starting Git maintenance for background optimization..."
git maintenance start

# Schedules pack, fetch, and GC to run silently in the background.

