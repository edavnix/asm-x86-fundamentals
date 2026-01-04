; ==============================================================================
; Exercise: 01_arithmetic_operations.asm
; Description: Performs basic arithmetic operations between two operands
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Supports signed 16-bit integers (loaded as 64 bits)
; - Handles negative results correctly
; - Detects and reports division by zero
; - Uses signed multiplication and division (imul, idiv)
; ==============================================================================

section .data
  operand1        dw 10
  operand2        dw 10

  msg_add         db "Addition = "
  len_add         equ $ - msg_add
  msg_sub         db "Subtraction = "
  len_sub         equ $ - msg_sub
  msg_mul         db "Multiplication = "
  len_mul         equ $ - msg_mul
  msg_div         db "Division = "
  len_div         equ $ - msg_div
  msg_div_zero    db "Error: Division by zero", 0xA
  len_div_zero    equ $ - msg_div_zero

  newline         db 0xA
  len_nl          equ 1

section .bss
  buffer resb 20

section .text
  global _start
  default rel                   ; position-independent code

print_str:
  push rax
  push rdi
  mov rax, 1                    ; sys_write
  mov rdi, 1                    ; stdout
  syscall
  pop rdi
  pop rax
  ret

number_to_string:
  push rbx
  push rcx
  lea rbx, [buffer + 19]        ; point to the end of the buffer
  mov byte [rbx], 0             ; null terminator
  xor rcx, rcx                  ; sign flag
  test rax, rax
  jns .is_positive              ; jump if non-negative (SF=0)
  neg rax                       ; make rax positive
  inc rcx                       ; set sign flag

.is_positive:
  mov rdi, 10

.divide_loop:
  dec rbx
  xor rdx, rdx
  div rdi                       ; unsigned divide rax by 10
  add dl, '0'                   ; convert remainder to ASCII
  mov [rbx], dl
  test rax, rax
  jnz .divide_loop
  test rcx, rcx                 ; was it negative?
  jz .done
  dec rbx
  mov byte [rbx], '-'           ; add negative sign

.done:
  mov rsi, rbx
  lea rdx, [buffer + 19]
  sub rdx, rbx
  pop rcx
  pop rbx
  ret

print_result:
  call print_str                ; print message (rsi/rdx already set)
  call number_to_string         ; convert rax to string (updates rsi/rdx)
  call print_str                ; print number
  lea rsi, [newline]            ; print newline
  mov rdx, len_nl
  call print_str
  ret

_start:
  movsx r8, word [operand1]     ; load operand1 with sign
  movsx r9, word [operand2]     ; load operand2 with sign

  ; Addition
  lea rsi, [msg_add]
  mov rdx, len_add
  mov rax, r8                   ; load first operand
  add rax, r9                   ; perform addition
  call print_result

  ; Subtraction
  lea rsi, [msg_sub]
  mov rdx, len_sub
  mov rax, r8
  sub rax, r9
  call print_result

  ; Multiplication
  lea rsi, [msg_mul]
  mov rdx, len_mul
  mov rax, r8
  imul rax, r9
  call print_result

  ; Division
  cmp r9, 0
  je .division_by_zero
  mov rax, r8                   ; load operand1 into rax
  cqo                           ; sign-extend rax into rdx:rax
  idiv r9                       ; divide by r9 (result in rax)
  lea rsi, [msg_div]            ; load division message
  mov rdx, len_div              ; load message length
  call print_result             ; print message and rax
  jmp .exit

.division_by_zero:
  lea rsi, [msg_div_zero]
  mov rdx, len_div_zero
  call print_str

.exit:
  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
