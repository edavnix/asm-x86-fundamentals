; ==============================================================================
; Exercise: 04_gcd_lcm.asm
; Description: Calculates the GCD and LCM of two numbers entered by the user
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Reads two decimal numbers separated by a space
; - Validates that the characters are digits (0-9)
; - Calculates GCD using Euclid's algorithm
; - Calculates LCM using the formula: LCM(a,b) = (a * b) / GCD(a,b)
; - Correctly handles the case where one of the numbers is zero
; - Supports numbers up to 64 bits (assumes small input: 0-9999)
; ==============================================================================

section .data
  msg_input       db "Enter 2 numbers (0-9999) separated by a space: "
  len_input       equ $ - msg_input
  msg_gcd         db "  - GCD = "
  len_gcd         equ $ - msg_gcd
  msg_lcm         db "  - LCM = "
  len_lcm         equ $ - msg_lcm

  newline         db 0xA
  len_nl          equ 1

section .bss
  input_buffer    resb 128      ; buffer for raw input
  output_buffer   resb 32       ; buffer for converting numbers to text
  buffer_position resq 1        ; current position in input_buffer
  num1            resq 1        ; first number
  num2            resq 1        ; second number

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
  mov rdx, 100
  syscall
  mov qword [buffer_position], 0
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

parse_next_number:
  push rbx
  push rcx
  push rsi
  lea rsi, [input_buffer]
  add rsi, [buffer_position]
  xor rax, rax                  ; number accumulator
  xor rcx, rcx                  ; digits found flag

.skip_whitespace:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .done
  cmp bl, 0xA
  je .done
  cmp bl, ' '
  jne .convert
  inc rsi
  inc qword [buffer_position]
  jmp .skip_whitespace

.convert:
  movzx rbx, byte [rsi]
  cmp bl, '0'
  jl .done
  cmp bl, '9'
  jg .done
  sub bl, '0'
  imul rax, rax, 10
  add rax, rbx
  inc rsi
  inc qword [buffer_position]
  inc rcx                       ; mark as digit found
  jmp .convert

.done:
  test rcx, rcx                 ; if no digits, rax is 0
  pop rsi
  pop rcx
  pop rbx
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

print_result:
  call number_to_string         ; convert rax to string (updates rsi/rdx)
  call print_str                ; print number
  lea rsi, [newline]            ; print newline
  mov rdx, len_nl
  call print_str
  ret

calculate_gcd:
  push rbx
  push rdx
  test rax, rax
  jz .return_rbx
  test rbx, rbx
  jz .done

.euclid_loop:
  test rbx, rbx
  jz .done
  xor rdx, rdx
  div rbx                       ; rax / rbx, remainder in rdx
  mov rax, rbx                  ; a = b
  mov rbx, rdx                  ; b = remainder
  jmp .euclid_loop

.return_rbx:
  mov rax, rbx
  jmp .done

.done:
  pop rdx
  pop rbx
  ret

calculate_lcm:
  push rbx
  push rcx
  push rdx
  push r12
  ; LCM(a, b) = (a * b) / GCD(a, b)
  mov rcx, rax                  ; save a in rcx
  mov r12, rbx                  ; save b in r12
  call calculate_gcd            ; rax = GCD(a, b)
  test rax, rax                 ; division by zero guard
  jz .lcm_zero
  mov rbx, rax                  ; rbx = GCD
  mov rax, rcx                  ; rax = a
  mul r12                       ; rdx:rax = a * b
  div rbx                       ; rax = (a * b) / GCD
  jmp .done

.lcm_zero:
  xor rax, rax

.done:
  pop r12
  pop rdx
  pop rcx
  pop rbx
  ret

_start:
  lea rsi, [msg_input]
  mov rdx, len_input
  call print_str
  call read_stdin

  call parse_next_number
  mov [num1], rax
  call parse_next_number
  mov [num2], rax

  ; Calculate and print GCD
  mov rax, [num1]
  mov rbx, [num2]
  call calculate_gcd
  push rax                      ; save the GCD or use the result

  lea rsi, [msg_gcd]
  mov rdx, len_gcd
  call print_str
  pop rax                       ; restore GCD
  call print_result

  ; Calculate and print LCM
  mov rax, [num1]
  mov rbx, [num2]
  call calculate_lcm

  lea rsi, [msg_lcm]
  mov rdx, len_lcm
  call print_str
  call print_result

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
