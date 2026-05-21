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

# Reusable text banner: $(call print_banner,Your message)
define print_banner
box_width=50; \
inner_width=$$((box_width - 2)); \
message="$(1)"; \
message_length=$${#message}; \
padding=$$((inner_width - message_length)); \
left_padding=$$((padding / 2)); \
right_padding=$$((padding - left_padding)); \
top_border="$(TOP_LEFT_CORNER)"; \
bottom_border="$(BOTTOM_LEFT_CORNER)"; \
horizontal_line="$(HORIZONTAL_LINE)"; \
vertical_line="$(VERTICAL_LINE)"; \
for ((i=0; i<box_width-2; i++)); do top_border="$$top_border$$horizontal_line"; bottom_border="$$bottom_border$$horizontal_line"; done; \
top_border="$$top_border$(TOP_RIGHT_CORNER)"; \
bottom_border="$$bottom_border$(BOTTOM_RIGHT_CORNER)"; \
printf "%s\n" "$$top_border"; \
printf "%s%*s%s%*s%s\n" "$$vertical_line" "$$left_padding" '' "$$message" "$$right_padding" '' "$$vertical_line"; \
printf "%s\n" "$$bottom_border"
endef

define print_error
echo -e "$(FAIL) $(1)$(RESET)"
endef

define print_success
echo -e "$(SUCCESS) $(1)$(RESET)"
endef

.PHONY: help
help: ## Show available targets
	@$(call print_banner,Available Makefile Targets)
	@echo ""
	@grep -hE '^[a-zA-Z_-]+:.*## .*$$' Makefile | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  $(CYAN)%-25s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ── Utils ────────────────────────────────────────────────────────────────
.PHONY: update-submodules
update-submodules: ## Update git submodules
	@$(call print_banner,Updating Git Submodules)
	@git submodule update --init --recursive --remote
	@$(call print_success,Git submodules updated successfully!)

.PHONY: delete-remote-branches
delete-remote-branches: ## Delete remote branches passed as arguments, e.g., `make delete-remote-branches branch1`
	@$(call print_banner,Deleting Remote Branches)
	@bash ./vendor/scripts/git/delete_remote_branches.sh $$@
	@$(call print_success,Remote branches deleted successfully!)

.PHONY: clone-scripts-submodule
clone-scripts-submodule: ## Clone the scripts submodule
	@$(call print_banner,Cloning Scripts Submodule)
	@git submodule add https://github.com/danielfdez17/scripts.git ./vendor/scripts
	@$(call print_success,Scripts submodule cloned successfully!)

.PHONY: remove-scripts-submodule
remove-scripts-submodule: ## Remove the scripts submodule
	@$(call print_banner,Removing Scripts Submodule)
	@bash ./vendor/scripts/git/remove_submodule.sh vendor/scripts
	@$(call print_success,Scripts submodule removed successfully!)

.PHONY: merge-to-dev
merge-to-dev: ## Merge the current branch into 'develop'
	@$(call print_banner,Merging Current Branch into 'dev')
	@bash ./vendor/scripts/git/merge_to_dev.sh
	@$(call print_success,Current branch merged into 'dev' successfully!)

.PHONY: merge-dev-to-main
merge-dev-to-main: ## Merge 'develop' into 'main'
	@$(call print_banner,Merging 'develop' into 'main')
	@bash ./vendor/scripts/git/merge_dev_to_main.sh
	@$(call print_success,'develop' merged into 'main' successfully!)

.PHONY: push-to-origin
push-to-origin: ## Push the current branch to 'origin'
	@$(call print_banner,Pushing Current Branch to 'origin')
	@bash ./vendor/scripts/git/push_to_origin.sh
	@$(call print_success,Current branch pushed to 'origin' successfully!)

.PHONY: collect-git-commit-history
collect-git-commit-history: ## Collect git commit history into a file
	@$(call print_banner,Collecting Git Commit History)
	@cd 42/transcendencegss; rm -rf commits.sqlite3; python3 store_github_commit_history.py --repos-file transcendence_local.txt --db commits.sqlite3
	@$(call print_success,Git commit history collected successfully!)