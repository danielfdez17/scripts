#!/usr/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# Scaffold a small GNU Make layout that stays easy to extend:
#
#   Makefile       entry point: default goal, then explicit module includes
#   mk/config.mk   shell, colors, and overridable command defaults
#   mk/help.mk     self-documenting help target
#   mk/git.mk      git submodule targets
#
# .DEFAULT_GOAL is set before any include so a target inside mk/ cannot
# become the default. Modules are included by name, in order, because a
# wildcard include hides dependencies between fragments.
#
# Usage: create_makefile.sh [destination]
# Existing Makefile or mk/*.mk files are left untouched.

destination="${1:-.}"
mk_dir="${destination}/mk"

refuse_if_present() {
	local path="$1"
	if [[ -e "$path" ]]; then
		printf 'Refusing to overwrite %s\n' "$path" >&2
		exit 1
	fi
}

write_makefile() {
	cat <<'EOF' > "${destination}/Makefile"
# Entry point. Set the default goal before including modules so a target
# defined in mk/*.mk cannot become the default.
#
# Add a module by creating mk/<name>.mk and appending an include below.
.DEFAULT_GOAL := help

include mk/config.mk
include mk/help.mk
include mk/git.mk
EOF
}

write_config_mk() {
	cat <<'EOF' > "${mk_dir}/config.mk"
# Shared configuration.
# Values assigned with ?= can be overridden from the command line, or from
# the root Makefile before this file is included.

SHELL := /usr/bin/bash
.SHELLFLAGS := -ec

GREEN := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
RESET := $(shell printf '\033[0m')
CYAN := $(shell printf '\033[0;36m')
ORANGE := $(shell printf '\033[0;31m')
RED := $(shell printf '\033[0;31m')
SUCCESS := $(GREEN)✓
FAIL := $(RED)✗
INFO := $(CYAN)ℹ
WARN := $(YELLOW)⚠

PRINT_BANNER ?= ./scripts/bash/print_banner.sh
PRINT_SUCCESS ?= ./scripts/bash/print_success.sh
PRINT_FAIL ?= ./scripts/bash/print_fail.sh
PRINT_INFO ?= ./scripts/bash/print_info.sh
PRINT_WARN ?= ./scripts/bash/print_warning.sh

RUN_AND_LOG ?= ./scripts/bash/run_and_log.sh

COMPOSE ?= docker compose
EOF
}

write_help_mk() {
	cat <<'EOF' > "${mk_dir}/help.mk"
# ── Utils

.PHONY: help
help: ## Show available targets
	@$(PRINT_BANNER) "Available Makefile Targets"
	@LC_ALL=C.UTF-8 awk '\
		function trim(s) { \
			sub(/^[[:space:]]+/, "", s); \
			sub(/[[:space:]]+$$/, "", s); \
			return s \
		} \
		/^# ──[[:space:]]+/ { \
			title = $$0; \
			sub(/^# ──[[:space:]]+/, "", title); \
			sub(/[[:space:]]*─+[[:space:]]*$$/, "", title); \
			title = trim(title); \
			n++; kind[n] = "section"; text[n] = title; \
			next \
		} \
		/^[a-zA-Z_-]+:.*## / { \
			name = $$0; sub(/:.*/, "", name); \
			msg = $$0; sub(/^[^#]*## /, "", msg); \
			n++; kind[n] = "target"; names[n] = name; msgs[n] = msg; \
			if (length(name) > name_width) name_width = length(name); \
			next \
		} \
		END { \
			for (i = 1; i <= n; i++) \
				if (kind[i] == "target") { \
					line = 2 + name_width + 1 + length(msgs[i]); \
					if (line > line_width) line_width = line \
				} \
			for (i = 1; i <= n; i++) \
				if (kind[i] == "section") { \
					label = "── " text[i] " "; \
					pad = line_width - length(label); \
					if (pad < 1) pad = 1; \
					dashes = ""; \
					for (j = 0; j < pad; j++) dashes = dashes "─"; \
					printf "%s%s\n", label, dashes \
				} else \
					printf "  $(CYAN)%-*s$(RESET) %s\n", name_width, names[i], msgs[i] \
		}' $(MAKEFILE_LIST)
EOF
}

write_git_mk() {
	cat <<'EOF' > "${mk_dir}/git.mk"
# ── Git

.PHONY: update-submodules
update-submodules: ## Update git submodules
	@$(PRINT_BANNER) "Updating Git Submodules"
	@git submodule update --init --recursive --remote
	@$(PRINT_SUCCESS) "Git submodules updated successfully!"
EOF
}

mkdir -p "$mk_dir"

for path in \
	"${destination}/Makefile" \
	"${mk_dir}/config.mk" \
	"${mk_dir}/help.mk" \
	"${mk_dir}/git.mk"
do
	refuse_if_present "$path"
done

write_makefile
write_config_mk
write_help_mk
write_git_mk

printf 'Created modular makefile in %s\n' "$destination"
printf '  %s\n' "${destination}/Makefile" "${mk_dir}/config.mk" "${mk_dir}/help.mk" "${mk_dir}/git.mk"
