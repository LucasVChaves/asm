section .text

exit:
    xor rdi, rdi              ; exit code 0
    mov rax, 60               ; exit syscall flag
    syscall

string_length:
    xor rax, rax              ; zeroing rax to store str length
.loop:
    cmp byte [rdi + rax], 0   ; checks if current symbol = 0 (null terminator)
    je .end                   ; jmp if true
    inc rax                   ; increase counter
    jmp .loop
.end:
    ret

print_char:
    push rdi                  ; pushes argument to stack
    mov rdi, rsp              ; copies value from stackptr to rdi
    call print_string
    pop rdi                   ; pops value com stack
    ret

print_newline:
    mov rdi, 10               ; 10 = new line symbol 
    jmp print_char    

print_string:
    push rdi                  ; push arg to stack
    call string_length        ; get str length
    pop rsi
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    ret

print_uint:
    mov rax, rdi
    mov rdi, rsp              ; value from stackptr to str (head of stack)
    push 0                    ; push null terminator to stack
    sub rsp, 10               ; reserves 16bytes to store 64bit unsigned int  

    dec rdi                   ; moves rdi to the pos before '\0', opening space for the first char 
                              ; of the str, allowing the chars to be stored back to front
    mov r8, 10                ; 10 stands for decimal, will be used to divide and extract digits
.loop:
    xor rdx, rdx              ; zeroes rdx
    div r8                    ; division, rax is quotient and rdx is the remainder wich represents
                              ; the ASCII char of the current digit
    or dl, 0x30               ; dl is the lesser byte of rdx, this instruction converts the hex of
                              ; a 0-9 digit to their respective ASCII decimal number
    dec rdi                   ; decreases the pointer to store the next digit
    mov [rdi], dl             ; inserts the converted digit into the correct pos
    test rax, rax             ; if the quotient (rax) is zero all numbers have been processed 
    jnz .loop

    call print_string

    add rsp, 24               ; clears the stack from 24 used bytes: 8 from 'push 0' + 16 from
                              ; 'sub rsp, 18'
    ret

print_int:
    test rdi, rdi             ; test if int is signed
    jns print_uint            ; if not signed jmp to print_uint
    push rdi                  ; push int to stack
    mov rdi, '-'              ; sign char to rdi (only negative ints are treated in this subrotine)
    call print_char           ; prints the sign char
    pop rdi                   ; pops sign char
    neg rdi                   ; inverts value
    jmp print_uint            ; prints the unsigned int

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    mov al, byte [rdi]        ; moves rdi pointer size to 'al'
    cmp al, '-'               ; checks if is signed int
    je .signed                ; if is signed this subrotine will process it
    jmp parse_uint            ; if not uint subrotine will process it 
.signed:
    inc rdi                   ; increase pointer = step to next char in string
    call parse_uint
    neg rax                   ; invert value in rax
    test rdx, rdx             ; test to check if zero
    jz .error                 ; if zero jmp to error

    inc rdx                   ; else increase rdx value (length)
    ret
.error:
    xor rax, rax              ; zero rax
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    mov r8, 10                ; base 10 for decimal
    xor rax, rax              ; zeroes rax to store final numeric value
    xor rcx, rcx              ; zeroes rcx to store counter index
.loop:
    movzx r9, byte [rdi + rcx]; moves with 0 extention for 64 bits to r9 
    cmp r9b, '0'              ; if char is less then 0 (non numeric digit)
    jb .end                   ; jmp to end if below (unsigned less then)
    cmp r9b, '9'              ; if char is bigger then 9 (non numeric digit)
    ja .end                   ; jmp to end if above (unsigned bigger then)
    xor rdx, rdx              ; clears rdx because mul uses rdx:rax as input
    mul r8                    ; multiplies rax by 10 (content of r8)
    and r9b, 0x0f             ; extracts the numeric value of the ASCII char
    add rax, r9               ; updates the accumulated numeric value with new digit
    inc rcx                   ; steps to next digit
    jmp .loop
.end:
    mov rdx, rcx              ; returns the length in rdx
    ret

string_equals:
    mov al, byte[rdi]         ; moves the first byte of the str to 'al'
    cmp al, byte [rsi]        ; compares with the fist byte of the other str
    jne .not_equal            ; if not equal jmp to end
    inc rdi                   ; else steps to next char
    inc rsi                   ; steps to next char in the second str as well
    test al, al               ; test if the current char is null terminator (0)
    jnz string_equals         ; if is not, calls the subrotine again on the next chars
    mov rax, 1                ; returns 1 if is equal
    ret
.not_equal:
    xor rax, rax              ; returns 0 if no equal
    ret 

; rdi: source rsi: dest rdx: destlen
string_copy:
    push rdi                  ; |
    push rsi                  ; |
    push rdx                  ; pushes src, dest an destlen to stack
    call string_length
    pop rdi
    pop rsi
    pop rdx
    
    cmp rax, rdx              ; if rax (strlen) bigger then rdx
    jae .too_long             ; jmp to label too_long
    push rsi                  ; push rsi to stack
.loop:
    mov dl, byte [rdi]        ; moves first byte of rdi (src) to dl
    mov byte[rsi], dl         ; moves dl (first byte of rdi) to first byte of rsi (dest)
    inc rdi                   ; step 1 char in src
    inc rsi                   ; step 1 char in dest
    test dl, dl               ; test if current char is 0 (null terminator)
    jnz .loop                 ; if not, iterate

    pop rax                   ; remove previous size from stack
    ret

.too_long:
    xor rax, rax              ; if too long to copy just returns 0
    ret

read_char:
    push 0
    xor rax, rax              ; rax 0 = read syscall
    xor rdi, rdi              ; fd (file descriptor) 0 = stdin
    mov rsi, rsp,             ; address of first byte of the input buffer
    mov rdx, 1                ; count (amount of bytes to read)
    syscall
    pop rax                   ; amount of read bytes, -1 if error
    ret 

read_word:
    push r14                  ; |
    push r15                  ; push r14 and r15 to stack to store original values
    xor r14, r14              ; zeroes r14
    mov r15, rsi              ; |
    dec r15                   ; defines the max length of the str (-1 due to 0-index)

.ignore_empty_chars:
    push rdi
    call read_char
    pop rdi
    cmp al, ' '               ; if char = space
    je .ignore_empty_chars
    cmp al, 10                ; if char = new line
    je .ignore_empty_chars
    cmp al, 13                ; if char = CR 
    je .ignore_empty_chars
    cmp al, 9                 ; if char = tab
    je .ignore_empty_chars
    test al, al               ; if char = \0 
    jz .end_ret

.read:
    mov byte [rdi + r14], al  ; store current char in memory 
    inc r14                   ; step to next char 

    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .end_ret
    cmp al, 10
    je .end_ret
    cmp al, 13
    je .end_ret
    cmp al, 9
    je .end_ret
    test al, al
    je .end_ret
    cmp r14, r15              ; r15 < 14
    je .too_long

    jmp .read

.end_ret:
    mov byte [rdi + r14], 0   ; insert null terminator at end
    mov rax, rdi              ; returns ptr of str
    mov rdx, r14              ; return strlen
    pop r15                   ; restores previous r15 value
    pop r14                   ; restores previous r15 value
    ret

.too_long:
    xor rax, rax              ; return 0 
    pop r15                   ; restores previous r15 value
    pop r14                   ; restores previous r15 value
    ret
