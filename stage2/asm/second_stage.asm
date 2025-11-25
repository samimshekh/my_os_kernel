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