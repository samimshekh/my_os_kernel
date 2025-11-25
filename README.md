# i8259 PIC Initialization in C
Is branch me humne **Programmable Interrupt Controller (PIC 8259A)** ko initialize kiya hai, jisse hardware interrupts (IRQ0–IRQ15) ko properly handle kiya ja sake.  
Ye OS development me ek important milestone hai, kyunki PIC initialize ke bina timer, keyboard, ya koi bhi external interrupt kaam nahi karega.

---

## Implemented Features

### Low-level Port I/O Functions
| Function | Description |
|----------|-------------|
| `outb(port, value)` | Ek 8-bit value ko I/O port par write karta hai |
| `inb(port)` | I/O port se ek 8-bit value read karta hai |
| `io_wait()` | PIC aur hardware stabilisation ke liye thoda delay add karta hai |

### PIC Remapping (IRQ0–IRQ15)
PIC ko remap kiya gaya hai:
- **Master PIC → 0x20**
- **Slave PIC  → 0x28**

---

## Quick Commands
```c
# Build 
make

# Run in QEMU
make run

# Clean build files
make clean
```