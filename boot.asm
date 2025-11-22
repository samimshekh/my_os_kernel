; Simple boot loader, prints 'OK'
org 0x7C00

mov ah, 0x0E
mov al, 'O'
int 0x10
mov al, 'K'
int 0x10

jmp $

times 510-($-$$) db 0
dw 0xAA55