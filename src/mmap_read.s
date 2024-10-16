; Using linux's mmap to read a file from memory
; Following the reference at https://lxr.missinglinkelectronics.com/linux+v3.14/include/uapi/asm-generic/mman-common.h#L9

%define O_RDONLY 0
%define PROT_READ 0x1
%define MAP_PRIVATE 0x2

section .data
fname: db 'test.txt', 0

section .text
global _start
; Extracted from libio

print_string:
    push rdi                  ; push arg to stack
    call string_length        ; get str length
    pop rsi
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    ret

string_length:
    xor rax, rax              ; zeroing rax to store str length
.loop:
    cmp byte [rdi + rax], 0   ; checks if current symbol = 0 (null terminator)
    je .end                   ; jmp if true
    inc rax                   ; increase counter
    jmp .loop
.end:
    ret

_start:
    ; Calls open from lxr
    mov rax, 2
    mov rdi, fname
    mov rsi, O_RDONLY         ; opens file as readonly
    mov rdx, 0                ; flag 0 = not creating file
    syscall

    ; mmap
    mov r8, rax               ; rax stores open file descriptor
    mov rax, 9                ; number for mmap syscall
    mov rdi, 0                ; OS will choose the map destiny
    mov rsi, 4096             ; page size
    mov rdx, PROT_READ        ; new memory region will be marked as readonly
    mov r10, MAP_PRIVATE      ; the pages wont be shared
    mov r9, 0                 ; offset in test.txt
    syscall

    mov rdi, rax
    call print_string

    mov rax, 60
    xor rdi, rdi
    syscall

