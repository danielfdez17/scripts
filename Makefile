SHELL := /usr/bin/bash
.SHELLFLAGS := -ec

BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m
CYAN := \033[0;36m
ORANGE := \033[0;31m
RED := \033[0;31m
SUCCESS := $(GREEN)✓
FAIL := $(RED)✗
INFO := $(CYAN)ℹ
WARN := $(YELLOW)⚠

.PHONY: help
.DEFAULT_GOAL := help

help: ## Show available targets
	@echo -e "$(CYAN)List of available targets$(RESET)"
	@echo ""
	@grep -hE '^[a-zA-Z_-]+:.*## .*$$' Makefile | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

