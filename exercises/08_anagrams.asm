; ==============================================================================
; Exercise: 08_anagrams.asm
; Description: Checks if two strings have the same characters
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Reads single input in format: "string1|string2"
; - Uses frequency tables to compare characters (256 ASCII)
; - read_stdin: Option 2 (internal storage for input_len)
; - compare_frequencies: Optimized with hardware 'repe cmpsb'
; ==============================================================================

section .data
  msg_input         db "Enter two strings separated by '|': "
  len_input         equ $ - msg_input
  msg_anagrams      db "  - YES, they are anagrams", 0xA
  len_anagrams      equ $ - msg_anagrams
  msg_not_anagrams  db "  - NO, they are not anagrams", 0xA
  len_not_anagrams  equ $ - msg_not_anagrams

section .bss
  input_buffer      resb 300    ; buffer for raw input
  input_len         resq 1      ; total input length
  buffer_position   resq 1      ; current position in input_buffer
  string1           resb 100    ; first extracted string
  string2           resb 100    ; second extracted string
  freq_table1       resb 256    ; frequency table for string1
  freq_table2       resb 256    ; frequency table for string2
  len1              resq 1      ; length of string1
  len2              resq 1      ; length of string2

section .text
  global _start
  default rel

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
  mov rdx, 300
  syscall
  mov [input_len], rax
  mov qword [buffer_position], 0
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

parse_input:
  push rbx
  push rcx
  push rsi
  push rdi
  lea rsi, [input_buffer]
  lea rdi, [string1]
  xor rcx, rcx

.find_separator:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_string1
  cmp bl, 0xA
  je .end_string1
  cmp bl, '|'
  je .found_separator
  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .find_separator

.found_separator:
  mov byte [rdi], 0
  mov [len1], rcx
  inc rsi
  lea rdi, [string2]
  xor rcx, rcx

.extract_string2:
  movzx rbx, byte [rsi]
  test bl, bl
  jz .end_string2
  cmp bl, 0xA
  je .end_string2
  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .extract_string2

.end_string2:
  mov byte [rdi], 0
  mov [len2], rcx
  jmp .done

.end_string1:
  mov byte [rdi], 0
  mov [len1], rcx
  mov qword [len2], 0

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

calculate_frequencies:
  push rax
  push rbx
  push rcx
  push rsi
  push rdi
  mov rbx, rcx

  ; Clear table (rdi already has the table address)
  push rdi
  mov rcx, 256
  xor al, al
  rep stosb                     ; clear 256 bytes with 0
  pop rdi

  ; Fill table
  mov rcx, rbx                  ; recover original rcx (length) from stack
  test rcx, rcx
  jz .done

.count_loop:
  movzx rax, byte [rsi]
  inc byte [rdi + rax]          ; increment frequency at ASCII index
  inc rsi
  loop .count_loop

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  pop rax
  ret

compare_frequencies:
  push rcx
  push rsi
  push rdi

  mov rcx, 256                  ; 256 ASCII entries
  repe cmpsb                    ; compare table1 and table2
  jne .different

  mov rax, 1                    ; Equal
  jmp .exit
.different:
  xor rax, rax                  ; Different
.exit:
  pop rdi
  pop rsi
  pop rcx
  ret

_start:
  lea rsi, [msg_input]
  mov rdx, len_input
  call print_str
  call read_stdin

  call parse_input

  ; Calculate Frequencies String 1
  lea rsi, [string1]
  mov rcx, [len1]
  lea rdi, [freq_table1]
  call calculate_frequencies

  ; Calculate Frequencies String 2
  lea rsi, [string2]
  mov rcx, [len2]
  lea rdi, [freq_table2]
  call calculate_frequencies

  ; Compare Tables
  lea rsi, [freq_table1]
  lea rdi, [freq_table2]
  call compare_frequencies

  test rax, rax
  jz .not_anagrams

  lea rsi, [msg_anagrams]
  mov rdx, len_anagrams
  call print_str
  jmp .end

.not_anagrams:
  lea rsi, [msg_not_anagrams]
  mov rdx, len_not_anagrams
  call print_str

.end:
  mov rax, 60
  xor rdi, rdi
  syscall
