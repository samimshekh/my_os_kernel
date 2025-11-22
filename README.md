# My OS Kernel - Bootloader (x86 i686)

## Overview
Is project me humne **simple bootloader** banaya hai jo screen pe `"OK"` print karta hai aur infinite loop me chala jata hai.

---

## Architecture
- **Target Architecture:** x86 i686 (32-bit)
- **Boot Mode:** BIOS (Real Mode)
- **Boot Sector Size:** 512 bytes
- **Boot Signature:** `0x55AA` (mandatory for BIOS recognition)

### Boot Sector Explanation
- **0x7C00** → BIOS bootloader load address
- **0x55AA** → Last 2 bytes of boot sector, BIOS ke liye **signature (0x55AA)** hai naho boot nahi hota hai
- **Boot code** → CPU initialization, screen output
- **Padding** → Boot sector ko exactly 512 bytes banane ke liye zero padding  

**Why 0x55AA?**  
BIOS boot process ke liye ye **magic signature** hota hai. Agar ye value last me nahi hogi, BIOS bootloader ko load nahi karega.

---

## Tools Required
1. **NASM** – Assembler for x86 (`nasm`)
2. **QEMU** – Emulator to run x86 images (`qemu-system-i386`)
3. **Make** – Automation tool (`make`)
4. **dd** – Binary copy to image file (Linux/WSL)

---

## Project Structure
```

.
├── boot.asm       # Bootloader assembly code
├── boot.bin       # Compiled binary (512 bytes)
├── boot.img       # Floppy image (1.44 MB)
└── Makefile       # Build automation

````

---

## Makefile Targets

- **Build bootloader binary and image**
```bash
make
````

* Steps:

  1. `boot.asm` → compiled to `boot.bin` (NASM)
  2. `boot.bin` → written to `boot.img` (1.44MB floppy image, `dd`)

* **Run bootloader in QEMU**

```bash
make run
```

* QEMU automatically boots `boot.img` and shows `"OK"` on the screen.

* **Clean build files**

```bash
make clean
```

* Removes `boot.bin` and `boot.img`.

---

---

## Notes

* Ye bootloader **x86 i686 BIOS real mode** ke liye hai.
* Bootloader ka size **exactly 512 bytes** hona chahiye.
* **0x55AA** end me hona mandatory hai.
* `Makefile` simple hai aur sab automated build/run steps handle karta hai. in sab ko aap bas **make && make run** kardo   

---

## Quick Commands

```bash
# Build bootloader
make

# Run in QEMU
make run

# Clean build files
make clean
```