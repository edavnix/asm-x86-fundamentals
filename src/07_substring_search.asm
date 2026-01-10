; ==============================================================================
; Exercise: 07_substring_search.asm
; Description: Searches for a substring within a main text
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Reads single input in format: "main text|substring"
; - Searches for substring using hardware-accelerated 'repe cmpsb'
; - Returns 0-based position or indicates failure
; - read_stdin: Option 2 (internal memory storage for length)
; ==============================================================================

section .data
  msg_input       db "Enter the main text and the substring separated by '|': "
  len_input       equ $ - msg_input
  msg_found       db "  - YES it is a substring (found at position "
  len_found       equ $ - msg_found
  msg_not_found   db "  - NO it is not a substring"
  len_not_found   equ $ - msg_not_found
  msg_close       db ")"
  len_close       equ 1

  newline         db 0xA
  len_nl          equ 1

section .bss
  input_buffer    resb 300      ; buffer for raw input
  main_text       resb 200      ; extracted main text
  search_text     resb 100      ; substring to search for
  output_buffer   resb 32       ; buffer for number conversion
  input_len       resq 1        ; length of total input
  main_len        resq 1        ; length of main text
  search_len      resq 1        ; length of substring
  buffer_position resq 1        ; current position in input_buffer

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

number_to_string:
  push rbx
  push rcx
  lea rbx, [output_buffer + 31] ; point to the end of the buffer
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
  lea rdx, [output_buffer + 31]
  sub rdx, rbx
  pop rcx
  pop rbx
  ret

parse_input:
  push rbx
  push rcx
  push rsi
  push rdi
  lea rsi, [input_buffer]
  lea rdi, [main_text]
  xor rcx, rcx                  ; counter

.find_separator:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_main
  cmp bl, 0xA
  je .end_main
  cmp bl, '|'
  je .found_separator
  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .find_separator

.found_separator:
  mov byte [rdi], 0
  mov [main_len], rcx
  inc rsi
  lea rdi, [search_text]
  xor rcx, rcx

.extract_search:
  movzx rbx, byte [rsi]
  test bl, bl
  jz .end_search
  cmp bl, 0xA
  je .end_search
  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .extract_search

.end_search:
  mov byte [rdi], 0
  mov [search_len], rcx
  jmp .done

.end_main:
  mov byte [rdi], 0
  mov [main_len], rcx
  mov qword [search_len], 0

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

find_substring:
  push rbx
  push rcx
  push rdx
  push rsi
  push rdi
  mov r12, rsi                  ; base main_text
  mov r13, rdi                  ; base search_text
  mov r14, rcx                  ; main_len
  mov r15, rdx                  ; search_len
  cmp r15, r14
  jg .not_found
  test r15, r15
  jz .found_at_zero
  mov rbx, r14
  sub rbx, r15                  ; rbx = max index to check
  xor r8, r8                    ; current index

.search_loop:
  cmp r8, rbx
  jg .not_found
  lea rsi, [r12 + r8]           ; main_text + offset
  mov rdi, r13                  ; search_text
  mov rcx, r15                  ; length to compare
  repe cmpsb                    ; compare until mismatch or rcx=0
  je .match_found               ; if ZF=1, we found it!
  inc r8
  jmp .search_loop

.match_found:
  mov rax, r8
  jmp .exit

.found_at_zero:
  xor rax, rax
  jmp .exit

.not_found:
  mov rax, -1

.exit:
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  ret

_start:
  lea rsi, [msg_input]
  mov rdx, len_input
  call print_str
  call read_stdin
  call parse_input

  mov rsi, main_text
  mov rdi, search_text
  mov rcx, [main_len]
  mov rdx, [search_len]
  call find_substring

  cmp rax, -1
  je .print_not_found

  push rax                      ; save found position
  lea rsi, [msg_found]
  mov rdx, len_found
  call print_str

  pop rax                       ; restore position
  call number_to_string
  call print_str                ; print position number

  lea rsi, [msg_close]
  mov rdx, len_close
  call print_str
  jmp .finish

.print_not_found:
  lea rsi, [msg_not_found]
  mov rdx, len_not_found
  call print_str

.finish:
  lea rsi, [newline]
  mov rdx, len_nl
  call print_str

  mov rax, 60
  xor rdi, rdi
  syscall
