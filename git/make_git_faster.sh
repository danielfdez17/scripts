#!/bin/bash

# Upgrade the index
git config feature.manyFiles true

# Switches Git to a format built for large repos -- faster status, add, and commit.

# Stop scanning everything
git config core.fsmonitor true

# OS watches the filesystem -- Git only checks files that actually changed.

# Background optimization
git maintenance start

# Schedules pack, fetch, and GC to run silently in the background.

