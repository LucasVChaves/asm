# asm
Programar em assembly é gostoso de mais

Este é um repositório de estudos de assembly, sei que tem muita coisa errada kkkk.

Estou utilizando o livro "Programação em Baixo Nível" do autor Igor Zhirkov. Ele aborda assembly e C para arquitetura Intel x86-64.

A pasta src possui alguns exercicios jogados.  
Já a pasta libio possui uma biblioteca para IO básica e código em python para testá-la. 

## Build
Estou usando o nasm para montar o código assembly e o ld para linkar o código objeto gerado.

```bash
    nasm -f elf64 -o programa_mto_foda.o main.s
    ld -o programa_mto_foda programa_mto_foda.o
```

## Run
Para rodar o programa basta executar o arquivo gerado.

```bash
    ./programa_mto_foda
```
