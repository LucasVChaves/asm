section .data
	hello:     db 'Hello, World!',10    ; 'Hello, World!' plus a linefeed character
	helloLen:  equ $-hello              ; len of string

section .text
	global _start

_start:
	mov eax,4            ; syscall (sys_write)
	mov ebx,1            ; file descriptor 1 (stdout)
	mov ecx,hello        ; put the offset of hello in ecx
	mov edx,helloLen     
	                     ; mov edx,[helloLen] to get its actual value
	int 80h              ; call the kernel
	mov eax,1            ; syscall (sys_exit)
	mov ebx,0            ; exit with return value of 0 (no error)
	int 80h;             ; call the kernel
