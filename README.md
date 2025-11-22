# Second Stage Loader (x86 i686)

## Overview
# Simple Multi-Stage Bootloader (Real Mode → Protected Mode 32-bit)

Ye project ek basic 2-stage bootloader example hai:

### Boot Flow
1. BIOS first sector ko `0x7C00` par load karta hai (`boot.asm`)
2. First stage disk se next sector load karke `0x7E00` par copy karta hai
3. A20 enable + GDT load hota hai
4. CPU protected mode enable hota hai
5. Far jump karke 32-bit code start hota hai (second_stage)
6. Assembly `entry` se `main()` call hota hai jo VGA pe text print karta hai

---

### Features
- Real mode boot sector (512 bytes, `0xAA55` signature)
- GDT setup for 32-bit code & data segment
- A20 line enable (8042 controller method)
- INT 13h disk read
- Protected mode switch (`CR0` PE=1)
- VGA text print from C code

---

### Build & Run
```bash
make clean
make
make run
````

### Requirements

```bash
sudo apt install nasm gcc-multilib qemu-system-i386 binutils
```

---

### Important Addresses

| Item                  | Address   |
| --------------------- | --------- |
| boot sector load      | `0x7C00`  |
| second stage load     | `0x7E00`  |
| VGA text buffer       | `0xB8000` |
| PM code jump selector | `0x08`    |

---

### Boot Device Handling

BIOS boot drive `DL` → `[bios_drive]` me save hota hai → `push edx` ke through `void main(short int d);` ko pass kiya jata hai.

---

### Test Output

Project run hone par VGA screen par message print hota:

```
Hello from C code...
```

---

### Clean

```bash
make clean
```