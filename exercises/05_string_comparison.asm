; ==============================================================================
; Exercise: 05_string_comparison.asm
; Description: Compares two strings entered on a single line or two lines
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Parses two text strings separated by spaces, tabs, or line breaks
; - Compares length and content byte by byte using hardware 'repe cmpsb'
; - Handles multiple separators and extra spaces
; ==============================================================================

section .data
  msg_input       db "Enter 2 strings separated by a space: "
  len_input       equ $ - msg_input
  msg_equal       db "  - The strings are EQUAL", 0xA
  len_equal       equ $ - msg_equal
  msg_different   db "  - The strings are DIFFERENT", 0xA
  len_different   equ $ - msg_different

section .bss
  input_buffer    resb 200      ; buffer for raw input
  string1         resb 100      ; first token
  string2         resb 100      ; second token
  len1            resq 1        ; length of token1
  len2            resq 1        ; length of token2
  buffer_position resq 1        ; current position in input_buffer

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

read_stdin:
  push rax
  push rdi
  push rsi
  push rdx
  mov rax, 0                    ; sys_read
  mov rdi, 0                    ; stdin
  lea rsi, [input_buffer]
  mov rdx, 200
  syscall
  mov qword [buffer_position], 0
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

parse_next_token:
  push rbx
  push rcx
  push rsi
  push rdi
  lea rsi, [input_buffer]
  add rsi, [buffer_position]
  mov rdi, r12                  ; r12 pointer to destination (passed as arg)
  xor rcx, rcx                  ; length counter = 0

.skip_whitespace:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .done
  cmp bl, 0xA
  je .done
  cmp bl, ' '
  jne .copy
  inc rsi
  inc qword [buffer_position]
  jmp .skip_whitespace

.copy:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .store_length
  cmp bl, ' '
  je .store_length
  cmp bl, 9
  je .store_length
  cmp bl, 0xA
  je .store_length
  cmp bl, 0xD
  je .store_length
  mov [rdi], bl                 ; copy byte to destination
  inc rdi
  inc rcx
  inc rsi
  inc qword [buffer_position]
  cmp rcx, 100                  ; protect buffer limits
  jge .store_length
  jmp .copy

.store_length:
  mov byte [rdi], 0             ; null-terminate string
  mov rax, rcx                  ; return length in rax

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

compare_strings:
  push rbx
  push rcx
  push rsi
  push rdi
  mov rcx, [len1]
  mov rdx, [len2]
  cmp rcx, rdx                  ; check if the lengths are different
  jne .different
  test rcx, rcx                 ; handle empty strings case
  jz .equal
  lea rsi, [string1]
  lea rdi, [string2]
  repe cmpsb                    ; compare [rsi] and [rdi] while ZF=1 and rcx > 0
  jne .different                ; if ZF=0 after loop, they differ

.equal:
  mov rax, 1                    ; return 1 (equal)
  jmp .done

.different:
  xor rax, rax                  ; return 0 (different)

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

_start:
  lea rsi, [msg_input]
  mov rdx, len_input
  call print_str
  call read_stdin

  ; Parse first string
  lea r12, [string1]
  call parse_next_token
  mov [len1], rax

  ; Parse second string
  lea r12, [string2]
  call parse_next_token
  mov [len2], rax

  call compare_strings
  test rax, rax
  jnz .is_equal

  lea rsi, [msg_different]
  mov rdx, len_different
  call print_str
  jmp .end

.is_equal:
  lea rsi, [msg_equal]
  mov rdx, len_equal
  call print_str

.end:
  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
