bits 16
%define ENDL 0x0D, 0x0A
%include "lode_file.asm"
__LODE_SECTOR equ (__lode_size / 512) + ((__lode_size % 512) != 0)
org 0x7c00
xor ax, ax      ; AX = 0, zero out the register
mov ds, ax      ; Set Data Segment (DS) = 0
mov sp, 0x7c00  ; Set Stack Pointer (SP) to 0x7C00
mov byte [bios_drive], dl ; Save boot drive number for later use
mov ax, 1                   ; LBA=1
mov cl, __LODE_SECTOR       ; sectors to read
mov bx, 0x7E00              ; load here
call disk_read
lgdt [gdt_descriptor]       ; GDT descriptor
cli
call enable_a20
xor dx, dx                  ; DX clear for safety
mov dl, [bios_drive]        ; Restore drive value pass c code drive value
mov eax, cr0                ; CR0 control register ko read karo (isme protection enable flag hota hai)
or eax, 1                   ; Bit 0 = PE (Protection Enable) ko set karo (OR 1)
mov cr0, eax                ; Updated value ko CR0 me wapas likho -> Protected mode enable ho gaya

jmp 0x08:protected_mode_32  ; Far jump to 32-bit code selector 0x08 (GDT code segment)
                           ; Ye jump pipeline flush karta hai, warna CPU abhi bhi real mode instructions samjhega

[BITS 32]
protected_mode_32:
    mov ax, 0x10            ; 0x10 = GDT data segment selector
    mov ds, ax              ; DS = 32-bit data segment
    mov es, ax              ; ES = 32-bit data segment
    mov ss, ax              ; SS = 32-bit stack segment (ab protected mode stack use karega)
    mov esp, 0x7c00         ; Stack pointer set karo (high memory pe safe location)
    
    jmp 0x7e00              ; Jump to second stage loader (already loaded at 0x7E00)
                           ; Ab aapka 32-bit code yaha se run hoga
bits 16
wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0

; ---------- LBA TO CHS ----------
lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track]

    inc dx
    mov cx, dx

    xor dx, dx
    div word [bdb_heads]

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al
    pop ax
    ret

; -------- DISK READ -----------
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call lba_to_chs
    pop ax

    mov ah, 02h
    mov di, 3
.retry:
    pusha
    stc
    int 13h
    jnc .done
    popa
    call disk_reset
    dec di
    jnz .retry
.fail:
    mov si, msg_read_failed
    call print
    jmp wait_key_and_reboot

.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret

floppy_error:
    mov si, msg_read_failed
    call print
    jmp wait_key_and_reboot

%include "print.asm"

enable_a20:
    call empty_8042       ; Wait until controller ready
    mov al, 0xD1          ; Command: Write Output Port
    out 0x64, al          ; Send command to PS/2 controller
    call empty_8042       ; Wait until ready again
    mov al, 0xDF          ; Output port value: A20 = 1
    out 0x60, al          ; Write value to output port
    call empty_8042       ; Wait for completion
    ret

; ---------------------------------------------------------
; Wait until PS/2 controller input buffer empty
; ---------------------------------------------------------
empty_8042:
    in al, 0x64           ; Read PS/2 status port
    test al, 2            ; Check IBF (bit 1 = Input Buffer Full)
    jnz empty_8042        ; If full, wait in loop
    ret

gdt_start:
    dq 0x0000000000000000         ; Null Descriptor

; 32-bit Code Segment Descriptor
; Base = 0x00000000, Limit = 0xFFFFF (4 GB), Access = 0x9A, Flags = 0xCF
gdt_code:
    dq 0x00CF9A000000FFFF

; 32-bit Data Segment Descriptor
; Base = 0x00000000, Limit = 0xFFFFF, Access = 0x92, Flags = 0xCF
gdt_data:
    dq 0x00CF92000000FFFF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; GDT size (limit)
    dd gdt_start                  ; GDT base (32-bit linear address)

msg_read_failed:  db 'Read from disk failed!', ENDL, 0
bdb_sectors_per_track: dw 18
bdb_heads:            dw 2
bios_drive: db 0  ; Boot drive stored here
times 510-($-$$) db 0
dw 0xAA55            ; BOOT SIGNATURE (MUST BE LAST)