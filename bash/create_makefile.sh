#!/usr/bin/bash

set -e # Exit immediately if a command exits with a non-zero status, and treat unset variables as an error when substituting.

# This script is used to create a default Makefile with some common targets for building and cleaning a project.
makefile_file_target=Makefile.template
cat <<EOL > $makefile_file_target
SHELL := /usr/bin/bash
.SHELLFLAGS := -ec

GREEN := \$(shell printf '\033[0;32m')
YELLOW := \$(shell printf '\033[0;33m')
RESET := \$(shell printf '\033[0m')
CYAN := \$(shell printf '\033[0;36m')
ORANGE := \$(shell printf '\033[0;31m')
RED := \$(shell printf '\033[0;31m')
SUCCESS := \$(GREEN)✓
FAIL := \$(RED)✗
INFO := \$(CYAN)ℹ
WARN := \$(YELLOW)⚠

PRINT_BANNER := ./scripts/bash/print_banner.sh
PRINT_SUCCESS := ./scripts/bash/print_success.sh
PRINT_FAIL := ./scripts/bash/print_fail.sh
PRINT_INFO := ./scripts/bash/print_info.sh
PRINT_WARN := ./scripts/bash/print_warn.sh

COMPOSE := docker compose

.DEFAULT_GOAL := help

help: ## Show available targets
	@\$(PRINT_BANNER) "Available Makefile Targets"
	@grep -hE '^[a-zA-Z_-]+:.*## .*\$\$' Makefile | \\
		awk 'BEGIN {FS = ":.*## "}; {printf "  \$(CYAN)%-15s\$(RESET) %s\n", \$\$1, \$\$2}'

# ── Utils ────────────────────────────────────────────────────────────────
.PHONY: update-submodules
update-submodules: ## Update git submodules
	@\$(PRINT_BANNER) "Updating Git Submodules"
	@git submodule update --init --recursive --remote
	@\$(PRINT_SUCCESS) "Git submodules updated successfully!"

EOL