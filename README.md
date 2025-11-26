# My OS Kernel – Overview

**Repository:** [my_os_kernel](https://github.com/samimshekh/my_os_kernel)  
**Architecture:** x86 i686 (32-bit)  
**Boot Mode:** BIOS Real Mode → Protected Mode  
**Purpose:** Bare-metal OS kernel development with complete bootloader, protected mode setup, interrupts, i8259 pic chip and basic VGA text output.

---

## Branch Overview

| Branch | Purpose | Key Features | Status / Next Steps |
|--------|---------|--------------|-------------------|
| `boot_sector` | First stage bootloader | - 512 bytes bootloader <br> - CPU initialization <br> - Prints `"OK"` on screen <br> - Infinite loop <br> - 0x55AA BIOS signature | Complete. Next: Load second stage loader |
| `second_stage_loader` | Second stage loader | - Loaded by first stage at 0x7E00 <br> - Reads sectors from floppy using BIOS INT 13h <br> - Prints `[INFO] Second Stage Loader successfully loaded` <br> - Infinite loop / waits for further tasks | Complete. Next: Switch to 32-bit protected mode |
| `32bit_c_code_loder` | 32-bit C loader | - Real Mode → Protected Mode switch <br> - VGA Text Mode support <br> - printf() with `%c, %s, %d, %u, %x, %b, %w` <br> - Cursor & screen color control <br> - Modular structure with stage2 C code | Complete. Next: Initialize GDT for memory segmentation |
| `protected_mode_gdt_in_c` | Global Descriptor Table (GDT) setup | - Full 32-bit protected mode GDT <br> - Kernel/User segments <br> - Selector macros (CS/DS, RPL0/RPL3) <br> - Ready for bare-metal C kernel | Complete. Next: Set up IDT for interrupts |
| `idt-setup-in-c` | Interrupt Descriptor Table (IDT) | - 256 IDT entries <br> - ISR stubs (`isr0`–`isr255`) <br> - Exception & IRQ handlers <br> - `lidt` instruction to load IDT <br> - Syscall entry at 128 | Complete. Next: Initialize PIC for hardware IRQs |
| `i8259-pic-remap` | PIC Initialization | - 8259A PIC remapping (Master 0x20, Slave 0x28) <br> - Port I/O functions: `outb`, `inb`, `io_wait` <br> - Hardware interrupts (IRQ0–IRQ15) ready | Complete. Next: Kernel scheduler, drivers, and system calls |

---

## Project Flow

1. **BIOS loads first stage bootloader** (`boot_sector`) at `0x7C00`.  
2. **First stage loader** loads second stage loader (`second_stage_loader`) at `0x7E00`.  
3. **Second stage C loader** (`32bit_c_code_loder`) switches CPU to 32-bit protected mode and initializes VGA/printf system.  
4. **GDT** (`protected_mode_gdt_in_c`) sets up kernel and user memory segments.  
5. **IDT** (`idt-setup-in-c`) sets up interrupt handling (exceptions, IRQs, syscalls).  
6. **PIC** (`i8259-pic-remap`) remaps IRQs and enables hardware interrupts.  
7. **Future:** Kernel scheduler, memory manager, device drivers, filesystem, and extended system calls.

---

## Project Structure (Simplified)

```
.
├── Makefile
├── README.md
├── boot
│   ├── Makefile
│   ├── boot.asm
│   ├── lode_file.asm
│   └── print.asm
├── build
└── stage2
    ├── Makefile
    ├── asm
    │   ├── include
    │   │   └── isr.asm
    │   └── second_stage.asm
    ├── c
    │   ├── linker.ld
    │   └── main.c
    └── include
        ├── cpu
        │   ├── gdt.h
        │   ├── i8259.h
        │   ├── idt.h
        │   ├── isr.h
        │   └── isr_handler.h
        ├── io.h
        ├── stdio.h
        └── type.h

````

---

## Build & Run

```bash
# Clean previous build
make clean

# Build bootloader + second stage + protected mode + GDT/IDT/PIC
make

# Run in QEMU
make run
````

---

## References

* Intel® 64 and IA-32 Architectures Software Developer’s Manual, Vol 3A (System Programming Guide)
* Ralf Brown's Interrupt List (INT 13h, INT 10h)

---

## Notes

* Branches should ideally be merged in this sequence to maintain proper dependency:

  1. `boot_sector`
  2. `second_stage_loader`
  3. `32bit_c_code_loder`
  4. `protected_mode_gdt_in_c`
  5. `idt-setup-in-c`
  6. `i8259-pic-remap`
