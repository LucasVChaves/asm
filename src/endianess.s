section .data
newline_char: db 10
codes: db '0123456789abcdef'
demo1: dq 0x1122334455667788
demo2: db 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88

section .text
global _start

print_newline:
    mov rax, 1              ; syscall write
    mov rdi, 1              ; file stdout descriptor
    mov rsi, newline_char
    mov rdx, 1              ; amount of bytes to write
    syscall
    ret

print_hex:
    mov rax, rdi
    mov rdi, 1
    mov rdx, 1
    mov rcx, 64
iterate:
    push rax                ; save the initial value to rax
    sub rcx, 4
    sar rax, cl             ; saves the initial value of rax
                            ; cl is the lesser part of rcx (last 4 bits)
    and rax, 0xf            ; clear all bits, except the last 4 significative
    lea rsi, [codes + rax]  ; gets the ASCII code from a hex digit

    mov rax, 1

    push rcx                ; syscall will operate in rcx
    syscall                 ; rax = 1 (31), write flag
                            ; rdi = 1, stdout flag
                            ; rsi = address of a char, as in line 28
    pop rcx
    pop rax
    test rcx, rcx           ; rcx = 0 when all digits are shown
    jnz iterate             ; while rcx != 0 then iterate

    ret

_start:
    mov rdi, [demo1]        ; moves the address of demo1 to rdi
    call print_hex
    call print_newline

    mov rdi, [demo2]        ; moves the address of demo22 to rdi
    call print_hex
    call print_newline


    mov rax, 60
    xor rdi, rdi
    syscall
