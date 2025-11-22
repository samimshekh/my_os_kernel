org 0x7e00          ; Load address of the second stage loader
start:
    mov si, msg      ; Load address of message string into SI
    call print       ; Call print.asm routine to print the string on screen
    jmp $            ; Infinite loop to halt execution

msg: db "[INFO] Second Stage Loader successfully loaded at 0x7E00 and running...", 0 ; Null-terminated string

%include "print.asm"  ; Include helper print routine (screen output)
