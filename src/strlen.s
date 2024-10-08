global _start

section .data
test_str: db "abcdef", 0

section .text

strlen:
    xor rax, rax                ; rax stores the str size, so it needs to be zeroed

.loop:
    cmp byte [rdi + rax], 0     ; checks if the current symbol = 0 (null terminator)
                                ; uses the 'byte' modifier because both sides must have
                                ; the same size
    je .end                     ; jump if cmp is true
    inc rax                     ; otherwise increases the counter

    jmp .loop

.end:
    ret


_start:
    mov rdi, test_str
    call strlen
    mov rdi, rax

    mov rax, 60
    syscall                       ; check this programs exit code
