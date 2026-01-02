# Justfile for asm-x86-fundamentals
# Documentation: https://just.systems/man/en/

set shell := ["bash", "-euo", "pipefail", "-c"]

# Assembler and Linker
ASM       := "nasm"
ASM_FLAGS := "-f elf64"
LD        := "ld"

# Temporary files
TARGET    := "exercise"
OBJ       := "exercise.o"

# Directories
SRC_DIR   := "src"

# Colors using ANSI escape codes
RED       := '\033[0;31m'
GREEN     := '\033[0;32m'
YELLOW    := '\033[0;33m'
CYAN      := '\033[0;36m'
GRAY      := '\033[0;90m'
END       := '\033[0m'

# Status Prefixes
ERROR     := RED    + "ERROR  " + END
INFO      := YELLOW + "INFO   " + END
SUCCESS   := GREEN  + "SUCCESS" + END
EXEC      := CYAN   + "EXEC   " + END

default: help

# Run a specific exercise. Usage: just run <file>
[no-exit-message]
run file_input:
  #!/usr/bin/env bash
  filename="{{file_input}}"
  [[ "$filename" != *.asm ]] && filename="${filename}.asm"

  # Search in current dir or src/
  if [[ -f "$filename" ]]; then
    target="$filename"
  elif [[ -f "{{SRC_DIR}}/$filename" ]]; then
    target="{{SRC_DIR}}/$filename"
  else
    echo -e "{{ERROR}} File '$filename' not found."
    exit 1
  fi

  # Assemble
  if ! {{ASM}} {{ASM_FLAGS}} "$target" -o {{OBJ}} 2>&1; then
    echo -e "{{ERROR}} Assembly failed for '$target'"
    exit 1
  fi

  # Link
  if ! {{LD}} {{OBJ}} -o {{TARGET}} 2>&1; then
    echo -e "{{ERROR}} Linking failed for '$target'"
    exit 1
  fi

  # Execute
  echo -e "{{EXEC}} Executing '$target'"
  ./{{TARGET}} || true
  echo -e "{{SUCCESS}} Execution finished"

  # Cleanup
  rm -f {{TARGET}} {{OBJ}}

# List exercises
[no-exit-message]
list:
  @echo -e "{{INFO}} Available exercises:"
  @ls {{SRC_DIR}}/*.asm 2>/dev/null | \
    xargs -n 1 basename | sed 's/^/  /' | column || \
    echo "  No files found"

# Check syntax
[no-exit-message]
check:
  #!/usr/bin/env bash
  echo -e "{{INFO}} Checking syntax..."

  # Check if directory exists
  [[ ! -d "{{SRC_DIR}}" ]] && {
    echo -e "{{ERROR}} Dir '{{SRC_DIR}}' not found."
    exit 1
  }

  passed=0 failed=0 found_files=0

  for file in {{SRC_DIR}}/*.asm; do
    [[ -e "$file" ]] || continue
    found_files=1

    if {{ASM}} {{ASM_FLAGS}} "$file" -o /tmp/test.o &>/dev/null; then
      ((passed++))
      rm -f /tmp/test.o
    else
      echo -e "{{RED}}  -> FAIL {{END}} $(basename "$file")"
      ((failed++))
    fi
  done

  [[ $found_files -eq 0 ]] && {
    echo -e "{{ERROR}} No files in {{SRC_DIR}}/"
    exit 1
  }

  echo -e "{{INFO}}" \
          "{{GREEN}}$passed passed {{END}},{{RED}} $failed failed {{END}}"

  [[ $failed -ne 0 ]] && exit 1

# Show help
help:
  @echo -e "{{INFO}} Usage:"
  @echo -e "  just run <file>   {{CYAN}}# Run specific file {{END}}"
  @echo -e "  just list         {{CYAN}}# List all exercises {{END}}"
  @echo -e "  just check        {{CYAN}}# Check syntax for all files {{END}}"
