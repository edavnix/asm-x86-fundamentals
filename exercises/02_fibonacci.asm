; ==============================================================================
; Exercise: 02_fibonacci.asm
; Description: Generates and displays the first N terms of the Fibonacci
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Handles signed numbers up to 64 bits
; - Prints each number followed by a newline
; - Recommended maximum: 93 terms (avoids 64-bit overflow)
; ==============================================================================

section .data
  newline         db 0xA
  len_nl          equ 1

section .bss
  buffer          resb 20

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
  call number_to_string         ; convert rax to string (updates rsi/rdx)
  call print_str                ; print number
  lea rsi, [newline]            ; print newline
  mov rdx, len_nl
  call print_str
  ret

_start:
  mov rbx, 0                    ; F(n-2) = 0
  mov r12, 1                    ; F(n-1) = 1
  mov r13, 93                   ; number of terms to print (maximum safe: 93)

  mov rax, rbx
  call print_result
  mov rax, r12
  call print_result

  sub r13, 2                    ; adjust counter (already printed 2 terms)
  jle .end                      ; sub already sets flags

.fib_loop:
  ; Calculate the next term: F(n) = F(n-2) + F(n-1)
  mov rax, rbx
  add rax, r12

  ; Update for next iteration
  mov rbx, r12                  ; F(n-2) = F(n-1)
  mov r12, rax                  ; F(n-1) = F(n)

  call print_result
  dec r13
  jnz .fib_loop

.end:
  lea rsi, [newline]
  mov rdx, len_nl
  call print_str

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
