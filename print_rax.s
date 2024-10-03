section .data
codes:
  db '0123456789ABCDEF'

section .text
global _start
_start:
  ; 1122 em hex
  mov rax, 0x1122334455667788

  mov rdi, 1 
  mov rdx, 1 
  mov rcx, 64
  ; cada 4 bits devem ser exibidos como um digito hex
  ; usa o shift e a operacao bit a bit AND para isolar
  ; o resultado eh o offset no array 'codes'
.loop:
  push rax
  sub rcx, 4
  ; cl eh um register, a parte menor de rcx
  ; rax -- eax -- ax -- ah + al
  ; rcx -- ecx -- cx -- ch + cl
  sar rax, cl
  and rax, 0xf

  lea rsi, [codes + rax]
  mov rax, 1 

  ; syscall deixa rcx e r11 alterados
  push rcx
  syscall
  pop rcx

  pop rax
  ; test pode ser usado para uma verificacao mais rapida do tipo 'is zero'
  ; consulte a documentacao do comando 'test'
  test rcx, rcx
  jnz .loop
  mov rax, 60 ; syscall exit
  xor rdi, rdi
  syscall
