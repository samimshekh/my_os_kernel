bits 16

extern __bss_start
extern __end
max_task_stack_size equ 100
max_task_make equ 50
%include "boot/multi-task.asm"

section .entry
global entry
entry:
    cli
    call init_irq0
    jmp init_task

kernel_main:
    fork task_1

    mov cx, 0x100
    .p:
    mov al, 'M'
    mov ah, 0xe
    int 0x10
    loop .p

    fork task_2

    mov cx, 0x100
    .p1:
    mov al, 'M'
    mov ah, 0xe
    int 0x10
    loop .p1
    exit

task_1:
    mov cx, 0x200
    .p:
    mov al, '1'
    mov ah, 0xe
    int 0x10
    loop .p 
    exit

task_2:
    mov cx, 0x100
    .p:
    mov al, '2'
    mov ah, 0xe
    int 0x10
    loop .p 
    exit