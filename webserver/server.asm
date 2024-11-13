section .data
    ; Syscall numbers
    socket  equ   41
    bind    equ   49
    listen  equ   50
    accept  equ   43
    read    equ   0
    write   equ   1
    open    equ   2
    close   equ   3
    exit    equ   60

    ; Consts
    af_inet        equ   2
    socket_stream  equ   1

    ; Server addr structure (AF_INET, port 8080, ip 127.0.0.1)
    address:
        dw af_inet
        dw 0x911F        ; Port 8080 in little-endian notation
        dd 0 
        dq 0 

    filename db "index.html", 0
    bufflen  equ 2048
    reqbuff  TIMES bufflen db 0
    resbuff  TIMES bufflen db 0

    ; HTTP response header
    header:
        db "HTTP/1.1 200 OK", 0Ah
        db "Date: xxx, xx xxx xxxx xx:xx:xx xxx", 0Ah
        db "Server: asm-server", 0Ah
        db "Content-Type: text/html", 0Ah, 0Ah, 0h
    headerlen equ $ - header

section .text
    global _start

_start:
    ; CREATE SOCKET
    mov rax, socket              ; sys_socket()
    mov rdi, af_inet             ; set socket addr family to AF_INET (IPv4)
    mov rsi, socket_stream       ; set scocket type to SOCK_STREAM (TCP)
    mov rdx, 0
    syscall
    mov r12, rax                 ; store server socket descriptor
    
    ; BIND SOCKET
    mov rax, bind                ; sys_bind()
    mov rdi, r12                 ; socket descriptor
    lea rsi, [address]           ; server address
    mov rdx, 16                  ; server address size
    syscall

    ; LISTEN ON SOCKET
    mov rax, listen              ; sys_listen()
    mov rdi, r12                 ; socket descriptor
    mov rsi, 10                  ; max number of pending connections
    syscall

accept_loop:
    ; ACCEPT CONNECTION
    mov rax, accept              ; sys_accept()
    mov rdi, r12                 ; socket descriptor
    mov rsi, 0
    mov rdx, 0
    syscall
    mov r13, rax                 ; client socket descriptor

    ; READ CLIENT REQUEST
    mov rax, read                ; sys_read()
    mov rdi, r13                 ; client socket descriptor
    mov rsi, reqbuff
    mov rdx, bufflen
    syscall

    ; LOG REQUEST TO STDOUT
    mov rax, write               ; sys_write()
    mov rdi, 1                   ; STDOUT file descriptor
    mov rsi, reqbuff
    mov rdx, bufflen
    syscall

    ; OPEN index.html FILE
    mov rax, open                ; sys_open()
    mov rdi, filename
    mov rsi, 0                   ; open file in READONLY
    syscall
    mov r14, rax                 ; store html file descriptor

    ; READ index.html CONTENT
    mov rax, read                ; sys_read()
    mov rdi, r14                 ; index.html file descriptor
    mov rsi, resbuff
    mov rdx, bufflen
    syscall

    ; SEND HTTP HEADER TO CLIENT
    mov rax, write               ; sys_write()
    mov rdi, r13                 ; client socket descriptor
    mov rsi, header
    mov rdx, headerlen
    syscall

    ; SEND HTML CONTENT TO CLIENT
    mov rax, write               ; sys_write()
    mov rdi, r13                 ; client socket descriptor
    mov rsi, resbuff
    mov rdx, bufflen
    syscall

    ; CLOSE CLIENT CONNECTION
    mov rax, close               ; sys_close()
    mov rdi, r13                 ; client socket descriptor
    syscall

    ; CLOSE index.html FILE
    mov rax, close               ; sys_close()
    mov rdi, r14                 ; html file descriptor
    syscall

    jmp accept_loop

exit_server:
    mov rax, exit                ; sys_exit()
    mov rdi, 0                   ; exit code 0
    syscall
