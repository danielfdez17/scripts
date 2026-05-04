# Upgrade the index
```bash
git config feature.manyFiles true
```

Switches Git to a format built for large repos -- faster status, add, and commit.

# Stop scanning everything
```bash
git config core.fsmonitor true
```

OS watches the filesystem -- Git only checks files that actually changed.

# Background optimization
```bash
git maintenance start
```

Schedules pack, fetch, and GC to run silently in the background.

