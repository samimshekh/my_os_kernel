# IDT (Interrupt Descriptor Table) Setup – x86 Kernel

### Overview
IDT (Interrupt Descriptor Table) ek important data structure hai jo CPU interrupts aur exceptions ko handle karta hai. Jab hardware interrupt aata hai (jaise keyboard, timer, mouse) ya CPU exception hota hai (Divide-by-zero, Page Fault, GPF, etc.), tab CPU interrupt number ke basis par IDT entry find karta hai aur respective ISR (Interrupt Service Routine) ko call karta hai.

Is project me humne:
- 256 IDT entries initialize ki
- Har interrupt ke liye `isr0` to `isr255` stub functions define kiye
- IDT pointer load kiya using `lidt` instruction
- Exception aur Hardware IRQ ke handlers register kiye

---

## Components

### **1. IDT Entry Structure**
```c
struct idt_entry {
    uint16_t base_low;   // ISR address lower 16 bits
    uint16_t sel;        // Kernel code segment selector (GDT)
    uint8_t  zero;       // Must be 0
    uint8_t  flags;      // Type and privilege flags
    uint16_t base_high;  // ISR address higher 16 bits
} __attribute__((packed));
````

### **2. IDT Pointer**

```c
struct idt_ptr {
    uint16_t limit;  // IDT size - 1
    uint32_t base;   // IDT array ka memory base address
} __attribute__((packed));
```

### **3. IDT Gate Set Function**

```c
void idt_set_gate(int num, uint32_t base, uint16_t sel, uint8_t flags)
{
    idt[num].base_low  = (base & 0xFFFF);
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].sel       = sel;
    idt[num].zero      = 0;
    idt[num].flags     = flags;
}
```

---

## **Initialize IDT**

```c
void Initialize_Idt()
{
    idtp.limit = sizeof(idt) - 1;
    idtp.base  = (uint32_t)&idt;

    idt_set_gate(0, (uint32_t)isr0, 0x08, 0x8E);
    idt_set_gate(1, (uint32_t)isr1, 0x08, 0x8E);
    ...
    idt_set_gate(31, (uint32_t)isr31, 0x08, 0x8E);

    idt_set_gate(32, (uint32_t)isr32, 0x08, 0x8E);  
    idt_set_gate(33, (uint32_t)isr33, 0x08, 0x8E);   
    ...
    idt_set_gate(47, (uint32_t)isr47, 0x08, 0x8E);

    // Reserved / Syscalls
    idt_set_gate(128, (uint32_t)isr128, 0x08, 0xEE); // System Call (user mode allowed)

    idt_load((uint32_t)&idtp);  // lidt instruction
}
```

---

## IDT Flags Meaning

| Flag         | Meaning                               |
| ------------ | ------------------------------------- |
| `0x8E`       | Present, Ring0, 32-bit interrupt gate |
| `0xEE`       | Present, Ring3, syscall enabled       |
| `SEL = 0x08` | Kernel Code Segment selector from GDT |

---

## Why 256 Entries?

| Range  | Description                                |
| ------ | ------------------------------------------ |
| 0–31   | CPU Exceptions                             |
| 32–47  | Hardware IRQs                              |
| 48–255 | Free / APIC / Syscalls / Custom interrupts |
| 128    | Linux-style system call number (standard)  |

---

## Flow of Interrupt Handling

```
Interrupt Occurs
        ↓
CPU checks IDT[index]
        ↓
Fetch ISR address
        ↓
Switch to kernel mode (if needed)
        ↓
Call ISR Stub (Assembly)
        ↓
Call C-level interrupt handler
        ↓
EOI (End of Interrupt) -> PIC/APIC
```

---

## Test & Debug Tips

| Command                      | Purpose                   |
| ---------------------------- | ------------------------- |
| `int $0x10`                  | Breakpoint interrupt test |
---

## Quick Commands
```c
# Build bootloader
make

# Run in QEMU
make run

# Clean build files
make clean
```