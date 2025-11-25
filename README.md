# 32-bit Protected Mode GDT Setup in c

Ye project **Global Descriptor Table (GDT)** ko setup karta hai taaki aapka kernel ya bare-metal C code 32-bit protected mode me run kar sake.  

---
## Features

- Fully **32-bit protected mode** GDT setup
- Kernel & user segments:
  - Kernel Code/Data (32-bit)
  - Kernel Code/Data (16-bit for backward compatibility)
  - User Code/Data (32-bit)
- Clear **selector macros** for easy use in C/ASM:

| Segment           | Selector |
|------------------|----------|
| Kernel CS (32-bit)| 0x08     |
| Kernel DS (32-bit)| 0x10     |
| Kernel CS (16-bit)| 0x18     |
| Kernel DS (16-bit)| 0x20     |
| User CS (32-bit)  | 0x28     |
| User DS (32-bit)  | 0x30     |

- Macros with **RPL (Requested Privilege Level)** for clarity:
  - `RPL0` = Kernel mode
  - `RPL3` = User mode

---

## How to Use

1. Include GDT header in your C kernel or ASM code:

```c
#include "cpu/gdt.h"
````

2. Initialize GDT:

```c
Initialize_GDT();  // Loads g_GDTDescriptor
```
---

## Notes

* GDT entry aur descriptor structures packed hai taaki memory layout sahi rahe.
* `GDT_ENTRY(base, limit, access, flags)` macro use kar sakte ho naya segment define karne ke liye.
* Ye setup **bare-metal C kernel development** ke liye ready hai.
* Compatible with bootloader jo **A20 line enable** aur **LGDT** call karta hai.

---

## References

* Intel® 64 and IA-32 Architectures Software Developer’s Manual, Vol 3A (System Programming Guide)
```