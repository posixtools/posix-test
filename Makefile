#=======================================================================================
# MAKE SETTINGS

.DEFAULT_GOAL := help
NAME := posix_test


#=======================================================================================
# HELP TARGET
#=======================================================================================

.PHONY: help
help:
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo "  $(NAME) make interface "
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   help              Prints out this help message."
	@echo "   init              Initializes the development environment."
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   test              Runs the included example test suite."
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo ""


#=======================================================================================
# INIT
#=======================================================================================
.PHONY: init
init:
	@git submodule update --init

#=======================================================================================
# TEST SUITE
#=======================================================================================
.PHONY: test
test:
	@./example/run.sh
