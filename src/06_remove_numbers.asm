; ==============================================================================
; Exercise: 06_remove_numbers.asm
; Description: Removes all digits from a string
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Filters all digits (0-9) from the string
; - Preserves all other characters
; - Displays the original string and the filtered string
; - Supports strings up to 200 characters long
; ==============================================================================

section .data
  msg_input       db "Enter a string: "
  len_input       equ $ - msg_input
  msg_original    db "  - Original string: "
  len_original    equ $ - msg_original
  msg_result      db "  - No numbers: "
  len_result      equ $ - msg_result

section .bss
  input_buffer    resb 200      ; buffer for raw input
  output_buffer   resb 200      ; buffer for string without numbers
  buffer_position resq 1        ; current position in input_buffer
  input_len       resq 1        ; input length
  output_len      resq 1        ; output length

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
  mov [input_len], rax
  mov qword [buffer_position], 0
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

remove_digits:
  push rbx
  push rcx
  push rsi
  push rdi
  xor rbx, rbx                  ; rbx = output length counter
  test rcx, rcx                 ; rcx = input length (from sys_read)
  jz .done

.process_loop:
  mov al, [rsi]                 ; load character from input
  cmp al, '0'
  jl .keep_char
  cmp al, '9'
  jle .skip_char                ; if between '0' and '9', do not copy

.keep_char:
  mov [rdi], al                 ; copy to output_buffer
  inc rdi
  inc rbx

.skip_char:
  inc rsi
  loop .process_loop            ; use rcx to loop

.done:
  mov rax, rbx                  ; return resulting length
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

  ; Show original string
  lea rsi, [msg_original]
  mov rdx, len_original
  call print_str

  lea rsi, [input_buffer]
  mov rdx, [input_len]
  call print_str

  ; Filter digits
  lea rsi, [input_buffer]
  lea rdi, [output_buffer]
  mov rcx, [input_len]
  call remove_digits
  mov [output_len], rax

  ; Show result
  lea rsi, [msg_result]
  mov rdx, len_result
  call print_str

  lea rsi, [output_buffer]
  mov rdx, [output_len]
  call print_str

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
