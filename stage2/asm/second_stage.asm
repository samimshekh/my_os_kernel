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

section .text
%include './asm/include/isr.asm'
[bits 32]
extern isr_handler     ; C handler

; ---------- Common ISR ----------
isr_common:
    ; push registers
    pusha              ; eax,ecx,edx,ebx,esp,ebp,esi,edi
    
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10        ; kernel data selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push esp            ; pointer to register dump
    call isr_handler   ; call C function
    add esp, 4          ; pop param

    pop gs
    pop fs
    pop es
    pop ds

    popad

    add esp, 8          ; remove int_no + error_code
    iret

[bits 32]
global idt_load

;extern void idt_load(uint32_t);
idt_load:
    mov eax, [esp+4]
    lidt [eax]
    ret

; void __attribute__((cdecl)) Load_GDT(GDTDescriptor* descriptor, uint16_t codeSegment, uint16_t dataSegment);
global Load_GDT
Load_GDT:
    ; make new call frame
    push ebp             ; save old call frame
    mov ebp, esp         ; initialize new call frame
    
    ; load gdt
    mov eax, [ebp + 8]
    lgdt [eax]

    ; reload code segment
    mov eax, [ebp + 12]
    push eax
    push .reload_cs
    retf

.reload_cs:

    ; reload data segments
    mov ax, [ebp + 16]
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax,
    mov ss, ax

    ; restore old call frame
    mov esp, ebp
    pop ebp
    ret