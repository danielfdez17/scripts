# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: danfern3 <danfern3@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/10/17 13:37:19 by danfern3          #+#    #+#              #
#    Updated: 2026/10/17 13:53:23 by danfern3         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SHELL := /usr/bin/bash
.SHELLFLAGS := -ec

BLUE := $(shell printf '\033[0;34m')
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

PRINT_BANNER := ./bash/print_banner.sh 
PRINT_SUCCESS := ./bash/print_success.sh 
PRINT_FAIL := ./bash/print_fail.sh 
PRINT_INFO := ./bash/print_info.sh 
PRINT_WARN := ./bash/print_warning.sh

RUN_AND_LOG := ./bash/run_and_log.sh


# * Top row (╭━━━╮) - round corners, full-span
# * Bottom row (╰━━━╯) - round corners, full-span
# * Merge row (┣━━━┫) - full-span, left/right T junctions
# * Merge-bottom (╰━━━╯) - alias for kind 3
# * Column cross (┣━╋━┫) - cross junctions (columns above/below)
# * Column open (┣━┳━┫) - T-down (columns start below)
# * Column close (┣━┻━┫) - T-up (columns end above)

TOP_LEFT_CORNER := $(ORANGE)╭$(RESET)
TOP_RIGHT_CORNER := $(ORANGE)╮$(RESET)
BOTTOM_LEFT_CORNER := $(ORANGE)╰$(RESET)
BOTTOM_RIGHT_CORNER := $(ORANGE)╯$(RESET)
HORIZONTAL_LINE := $(ORANGE)━$(RESET)
VERTICAL_LINE := $(ORANGE)┃$(RESET)
LEFT_JUNCTION := $(ORANGE)┣$(RESET)
RIGHT_JUNCTION := $(ORANGE)┫$(RESET)
CROSS_JUNCTION := $(ORANGE)┣$(RESET)$(ORANGE)━$(RESET)$(ORANGE)┫$(RESET)
OPEN_JUNCTION := $(ORANGE)┣$(RESET)$(ORANGE)━$(RESET)$(ORANGE)┫$(RESET)
CLOSE_JUNCTION := $(ORANGE)┣$(RESET)$(ORANGE)━$(RESET)$(ORANGE)┫$(RESET)

.DEFAULT_GOAL := help

.PHONY: help
# ── Utils
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
		}' Makefile

.PHONY: lint-bash-scripts
lint-bash-scripts: ## Lint all bash scripts in the repository
	@$(PRINT_BANNER) "Linting Bash Scripts"
	@$(RUN_AND_LOG) -c "./bash/lint_bash_scripts.sh"
	@$(PRINT_SUCCESS) "Bash scripts linted successfully!"

.PHONY: lint-python-scripts
lint-python-scripts: ## Lint all Python scripts in the repository
	@$(call print_banner,Linting Python Scripts)
	@./python/lint_python_scripts.py
	@$(PRINT_SUCCESS) "Python scripts linted successfully!"

.PHONY: lint
lint: ## Lint all bash and Python scripts
	@$(PRINT_BANNER) "Linting All Scripts"
	@$(MAKE) -s lint-bash-scripts
	@$(MAKE) -s lint-python-scripts
	@$(PRINT_SUCCESS) "All scripts linted successfully!"
