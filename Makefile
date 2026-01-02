# Makefile for asm-x86-fundamentals
# Documentation: https://www.gnu.org/software/make/manual/make.html
# Usage: make run file=exercises/<file.asm>

# Compiler and Flags
ASM       = nasm
ASM_FLAGS = -f elf64
LD        = ld

# Temporary file names
TARGET    = exercise
OBJ       = exercise.o

# Colors for the terminal
RED       = \033[0;31m
GREEN     = \033[0;32m
YELLOW    = \033[0;33m
CYAN      = \033[0;36m
NC        = \033[0m

# Status Prefixes
ERROR     = $(RED)[ ERROR ]$(NC)
INFO      = $(YELLOW)[ INFO  ]$(NC)
SUCCESS   = $(GREEN)[SUCCESS]$(NC)
EXEC      = $(CYAN)[ EXEC  ]$(NC)

.PHONY: run help

run:
	@if [ -z "$(file)" ]; then \
		printf "$(ERROR) $(RED) Error: No file specified. $(NC)\n"; \
		printf "$(INFO) $(YELLOW) Recommendation: Use the 'file=' variable to specify the path. $(NC)\n"; \
		printf "$(INFO) $(CYAN) Usage: make run file=exercises/<file.asm> $(NC)\n"; \
		exit 1; \
	fi

	@if [ ! -f "$(file)" ]; then \
		printf "$(ERROR) $(RED) Error: File '$(file)' not found. $(NC)\n"; \
		exit 1; \
	fi

	@case "$(file)" in \
		*.asm) ;; \
		*) printf "$(ERROR) $(RED) Error: '$(file)' is not a .asm file. $(NC)\n"; exit 1 ;; \
	esac

	@$(ASM) $(ASM_FLAGS) "$(file)" -o $(OBJ) || \
		(printf "$(ERROR) $(RED) Error: Assembly failure (nasm) $(NC)\n" && exit 1)

	@$(LD) $(OBJ) -o $(TARGET) || \
		(printf "$(ERROR) $(RED) Error: Linking failure (ld) $(NC)\n" && exit 1)

	@printf "$(EXEC) $(CYAN) Executing: $(file) $(NC)\n"
	@./$(TARGET)
	@printf "$(SUCCESS) $(GREEN) Success: Execution finished. $(NC)\n"

	@rm -f $(OBJ) $(TARGET)

help:
	@printf "$(INFO) $(CYAN) Usage: make run file=exercises/<file.asm> $(NC)\n"
	@printf "$(INFO) $(YELLOW) Recommendation: You can use TAB to autocomplete the path after 'file=' $(NC)\n"
	@printf "$(INFO) $(CYAN) Example: make run file=exercises/01_arithmetic_operations.asm $(NC)\n"
