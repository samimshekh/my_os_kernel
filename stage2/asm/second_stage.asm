section .entry
extern main
global entry

bits 32
entry:
    push edx
    call main
    cli
hang:
    hlt
    jmp hang