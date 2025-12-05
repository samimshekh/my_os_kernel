org 0x7c00
%define ENDL 0x0D, 0x0A
%include "boot/kernel_size.inc"
__lode equ ((kernel_size / 512) + ((kernel_size % 512) != 0));
section .boot_sector
mov ax, 1                   ; LBA=1
mov cl, __lode              ; sectors to read
mov bx, 0x7E00              ; load here
mov dl, 0x00                ; boot drive (floppy/hard disk)
call disk_read
jmp 0x7e00

wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0

puts:
    push si
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    pop bx
    pop ax
    pop si
    ret

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
    call puts
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
    call puts
    jmp wait_key_and_reboot

msg_read_failed:  db 'Read from disk failed!', ENDL, 0
bdb_sectors_per_track: dw 18
bdb_heads:            dw 2

times 510-($-$$) db 0
dw 0xAA55            ; BOOT SIGNATURE (MUST BE LAST)
