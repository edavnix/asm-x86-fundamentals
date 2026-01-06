; ==============================================================================
; Exercise: 03_prime_numbers.asm
; Description: Read 10 numbers from the user and display the prime numbers found
; Platform: Linux x86-64 (NASM)
; ==============================================================================
; Features:
; - Reads up to 100 bytes of standard input
; - Parses decimal numbers separated by spaces
; - Validates that characters are digits (0-9)
; - Detects prime numbers (includes 2 and 3, excludes < 2)
; - Supports signed numbers up to 64 bits
; - Prints primes separated by spaces and total count at the end
; ==============================================================================

section .data
  msg_input       db "Enter 10 numbers (0-9999) separated by spaces: "
  len_input       equ $ - msg_input
  msg_primes      db "  - Prime numbers: "
  len_primes      equ $ - msg_primes
  msg_count       db "  - Number of primes: "
  len_count       equ $ - msg_count

  space           db " "
  len_space       equ 1
  newline         db 0xA
  len_nl          equ 1

section .bss
  input_buffer    resb 128      ; buffer for raw input
  output_buffer   resb 32       ; buffer for converting numbers to text
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
  lea rsi, [space]              ; print space
  mov rdx, len_space
  call print_str
  ret

is_prime:
  push rbx
  push rcx
  push rdx
  push r12
  mov r12, rax                  ; save n in r12
  cmp r12, 2
  jl .not_prime                 ; n < 2 → not prime
  je .prime                     ; n == 2 → prime
  test r12, 1
  jz .not_prime                 ; even > 2 → not prime
  mov rbx, 3                    ; test odd divisors starting from 3

.test_loop:
  mov rax, rbx
  mul rax                       ; rax = rbx * rbx
  cmp rax, r12
  jg .prime                     ; if rbx² > n → is prime
  mov rax, r12
  xor rdx, rdx
  div rbx
  test rdx, rdx
  jz .not_prime                 ; divisible n % rbx == 0? → not prime
  add rbx, 2                    ; next odd number
  jmp .test_loop

.prime:
  mov rax, 1
  jmp .done

.not_prime:
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

  lea rsi, [msg_primes]
  mov rdx, len_primes
  call print_str

  xor r13, r13                  ; prime counter
  xor r15, r15                  ; index counter (for 10 numbers)

.check_loop:
  call parse_next_number
  test rax, rax                 ; check if we should process
  jz .skip_check
  mov r14, rax                  ; save current number
  call is_prime
  cmp rax, 1
  jne .skip_check
  mov rax, r14                  ; restore number to print
  call print_result
  inc r13                       ; increment primes found

.skip_check:
  inc r15
  cmp r15, 10
  jl .check_loop

  lea rsi, [newline]
  mov rdx, len_nl
  call print_str

  lea rsi, [msg_count]
  mov rdx, len_count
  call print_str

  mov rax, r13
  call number_to_string
  call print_str

  lea rsi, [newline]
  mov rdx, len_nl
  call print_str

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall
