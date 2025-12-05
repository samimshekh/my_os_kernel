%macro fork 1
    ;init task
    cli
    mov bx, sp
    add word [crt_stack_tracking], max_task_stack_size
    mov sp, word [crt_stack_tracking] 
    push word 0x0200   ; FLAGS
    push word 0x0000   ; CS
    push word %1   ; %2 IP 
    pusha
    mov bp, sp
    mov si, word [len_tasks]
    mov di, tesks_sp_reg_pointer
    add si, di
    mov word [si], bp 
    add word [len_tasks], 2
    mov sp, bx 
    sti
%endmacro

%macro exit 0
    jmp exit_task
%endmacro

init_task:
    mov word [crt_stack_tracking], __end

    mov sp, 0x7c00
    push word 0x0200   ; FLAGS
    push word 0x0000   ; CS
    push word kernel_main   ; IP
    jmp taskSwitch

init_irq0:
    ; ---------------------------
    ; Install handler in IVT[0x08]
    ; ---------------------------
    xor ax, ax
    mov ds, ax          
    mov si, 8*4

    mov ax, taskSwitch
    mov [ds:si], ax        

    mov ax, cs              
    mov [ds:si+2], ax       

    ; ---------------------------
    ; Unmask IRQ0 in PIC (clear bit0 of port 0x21)
    ; ---------------------------
    in al, 0x21
    and al, 0xFE           
    out 0x21, al

    ; ---------------------------
    ; PIT = 100 Hz
    ; ---------------------------
    mov al, 0x34
    out 0x43, al

    mov al, 0x9C       
    out 0x40, al
    mov al, 0x2E       
    out 0x40, al
    ret

taskSwitch:
    cli
    pusha
    mov si, tesks_sp_reg_pointer
    add si, word [crt_run_task]
    mov word [si], sp

    mov ax, word [len_tasks]
    add word [crt_run_task], 2
    cmp ax, word [crt_run_task]
    jne .ok
    mov word [crt_run_task], 0x0000
.ok:
    mov si, tesks_sp_reg_pointer
    add si, word [crt_run_task]
    mov sp, word [si]

    mov al, 0x20        ; PIC EOI
    out 0x20, al
    popa
    sti
    iret 

tesks_sp_reg_pointer: times max_task_make dw 0
len_tasks: dw 0x2
crt_run_task: dw 0x00 
crt_stack_tracking: dw 0x00 

exit_task:
    .hang:
        hlt
        jmp .hang