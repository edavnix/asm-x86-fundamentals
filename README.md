<div align="center">
  <h1>Assembly Exercises</h1>
  <p>Programming exercises in <strong>x86-64 Assembly</strong> using <strong>NASM (Netwide Assembler)</strong> syntax</p>

![Arch](https://img.shields.io/badge/Arch-1793D1?logo=archlinux&logoColor=1793D1&labelColor=fff&color=1793D1)
![Assembly](https://img.shields.io/badge/Assembly-007ACC?logo=assemblyscript&logoColor=007ACC&labelColor=fff&color=007ACC)
![NASM](https://img.shields.io/badge/NASM-007ACC?logo=assemblyscript&logoColor=007ACC&labelColor=fff&color=007ACC)

</div>

## Description

This repository contains programming exercises in **x86-64 Assembly** using **NASM**. Practical examples include:

- Direct interaction with Linux kernel syscalls.
- Handling 64-bit registers (`RAX`, `RBX`, `RCX`, `RDX`, etc.).
- Hardware-level operations.
- Memory and string manipulation.

## Exercises

| #   | Exercise                  | Level | Description                                                         |
| --- | ------------------------- | ----- | ------------------------------------------------------------------- |
| 1   | **Arithmetic Operations** | 🟢    | Addition, subtraction, multiplication, and division of two numbers. |
| 2   | **Fibonacci**             | 🟢    | Generates Fibonacci sequence from f(0) to f(93).                    |
| 3   | **Prime Numbers**         | 🟡    | Detects prime numbers among 10 input values.                        |
| 4   | **GCD and LCM**           | 🟡    | Calculates Greatest Common Divisor and Least Common Multiple.       |
| 5   | **String Comparison**     | 🟡    | Compares two strings to verify equality.                            |
| 6   | **Remove Numbers**        | 🟡    | Removes all numeric digits from a string.                           |
| 7   | **Substring Search**      | 🔴    | Detects a substring within another string.                          |
| 8   | **Anagrams**              | 🔴    | Verifies if two words are anagrams (same characters).               |

## Installation Requirements

- **Operating System**: Arch Linux or WSL2 on Windows.
- **Architecture**: x86-64 (64-bit).
- **NASM**: version 3.01 or higher.
- **GNU Linker (ld)**: version 2.45.1 or higher.
- **Just command runner**: version 1.46.0 or higher.

## Execution Instructions

### Arch Linux/WSL (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/edavnix/asm-x86-fundamentals.git
   ```
   > **Note**: When using Arch Linux natively, proceed to **Step 4**. For Windows environments, complete all steps to install and configure WSL Arch.
2. **Download and install WSL Arch** (PowerShell):
   ```bash
   wsl --install -d archlinux
   ```
3. **Restart the system** and access Arch Linux.
4. **Install NASM, compilation tools and Just**:
   ```bash
   pacman -Syu
   pacman -S nasm base-devel just
   ```
5. **Verify installation**:
   ```bash
   nasm --version   # e.g. NASM version 3.01
   ld --version     # e.g. GNU ld (GNU Binutils) 2.45.1
   just --version   # e.g. just 1.46.0
   uname -m         # e.g. x86_64
   ```
6. **Navigate to the directory**:
   ```bash
   cd asm-x86-fundamentals
   ```
7. **Execute exercises** use `just run` followed by the file name or path:
   ```bash
   just                                         # view available commands
   just list                                    # display exercises
   just run 01_arithmetic_operations.asm        # practical example by file name
   just run src/01_arithmetic_operations.asm    # practical example by full path
   just check                                   # verify that all exercises compile
   ```

### OneCompiler (No Installation Required)

Code execution without local installation:

1. Access **[OneCompiler - Assembly](https://onecompiler.com/assembly)**.
2. Copy and paste the exercise code.
3. For exercises requiring input:
   - Navigate to the **STDIN** panel.
   - Enter values separated by spaces.
4. Click **Run**.

## Official Documentation

Additional resources:

- **[NASM Documentation](https://www.nasm.us/doc/)** - Complete assembler manual.
- **[x86-64 Reference](https://www.felixcloutier.com/x86/)** - x86-64 instruction reference.
- **[Linux Syscall Call Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)** - Syscall table for x86-64.

<div align="center">
  <br>
  <img
    src="https://img.shields.io/badge/Made%20with-Assembly%20%26%20Curiosity-007ACC?style=for-the-badge"
    alt="Made with Assembly"
  />
  <br><br>
  <p>⭐ <strong>Star this repository to show support</strong> ⭐</p>
</div>
