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

.PHONY: help
# ── Utils
help: ## Show available targets
	@\$(PRINT_BANNER) "Available Makefile Targets"
	@LC_ALL=C.UTF-8 awk '\\
		function trim(s) { \\
			sub(/^[[:space:]]+/, "", s); \\
			sub(/[[:space:]]+\$\$/, "", s); \\
			return s \\
		} \\
		/^# ──[[:space:]]+/ { \\
			title = \$\$0; \\
			sub(/^# ──[[:space:]]+/, "", title); \\
			sub(/[[:space:]]*─+[[:space:]]*\$\$/, "", title); \\
			title = trim(title); \\
			n++; kind[n] = "section"; text[n] = title; \\
			next \\
		} \\
		/^[a-zA-Z_-]+:.*## / { \\
			name = \$\$0; sub(/:.*/, "", name); \\
			msg = \$\$0; sub(/^[^#]*## /, "", msg); \\
			n++; kind[n] = "target"; names[n] = name; msgs[n] = msg; \\
			if (length(name) > name_width) name_width = length(name); \\
			next \\
		} \\
		END { \\
			for (i = 1; i <= n; i++) \\
				if (kind[i] == "target") { \\
					line = 2 + name_width + 1 + length(msgs[i]); \\
					if (line > line_width) line_width = line \\
				} \\
			for (i = 1; i <= n; i++) \\
				if (kind[i] == "section") { \\
					label = "── " text[i] " "; \\
					pad = line_width - length(label); \\
					if (pad < 1) pad = 1; \\
					dashes = ""; \\
					for (j = 0; j < pad; j++) dashes = dashes "─"; \\
					printf "%s%s\n", label, dashes \\
				} else \\
					printf "  \$(CYAN)%-*s\$(RESET) %s\n", name_width, names[i], msgs[i] \\
		}' Makefile

.PHONY: update-submodules
update-submodules: ## Update git submodules
	@\$(PRINT_BANNER) "Updating Git Submodules"
	@git submodule update --init --recursive --remote
	@\$(PRINT_SUCCESS) "Git submodules updated successfully!"

EOL