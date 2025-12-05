# Multi-Tasking Bootloader & Kernel (x86, Real Mode)

Ye project ek **x86 real-mode bootloader aur simple multitasking kernel** ka implementation hai jo `IRQ0` timer ke through task switching karta hai. Ye project assembly (NASM) me likha gaya hai aur floppy/hard disk se boot hota hai.  

---

## Features

1. **Bootloader**
   - Real-mode (16-bit) boot sector at `0x7C00`.
   - Kernel ko LBA se CHS translate karke load karta hai.
   - Disk read error handling aur user prompt.

2. **Multitasking Kernel**
   - Task creation (`fork`) aur exit (`exit`) macros.
   - Task switching timer IRQ0 (PIT 100Hz) par.
   - Maximum task stack size configurable (`max_task_stack_size`).
   - Maximum tasks configurable (`max_task_make`).
   - Round-robin scheduling.
   - Simple text output using BIOS `int 0x10`.

3. **Tasks**
   - Example tasks `task_1` aur `task_2`.
   - Each task can print characters on screen.

---

## Task Management
    boot/multi-task.asm Task macros & kernel multitasking logic


## Overview

Is kernel/bootloader me **3 tasks** chal rahe hain:

1. **Main task** — screen par `M` print karta hai.
2. **task_1** — screen par `1` print karta hai.
3. **task_2** — screen par `2` print karta hai.

Main task dynamic tarike se `fork` karta hai: pehle `task_1` ko banata hai (jab main ne 0x100 cycles `M` print kar liye), phir kuch aur `M` prints ke baad `task_2` banata hai (jab main ne 0x100 cycles `M` print kar liye). Har task apne printing cycles khatam hone par `exit` karta hai.

---

## Kya hota hai — Scheduling ka behaviour (seedhe shabdon me)

* Kernel **timer (IRQ0)** ko 100 Hz par set karta hai. Iska matlab: har 10 ms ek context switch ho sakta hai.
* Jab timer interrupt aata hai, `taskSwitch` current task ka `SP` save karta hai aur next available task ka `SP` load karta hai — simple **round-robin** scheduling.
* Isliye screen output aise dikhai deta hai:

  * `MMMM...` (main task run karta hai apne time slice me),
  * phir `1111...` (task_1 run karta hai),
  * phir `2222...` (task_2 run karta hai),
  * phir wapas `MMMM...` — aur ye cycle chalti rehti hai jab tak tasks exit na kar den.

Ye alternating output isliye hota hai kyunki sab tasks CPU time slices share karte hain; har task ko ek chhota time quantum milta hai (PIT 100 Hz) — isiliye aapko continuous `M` phir `1` phir `2` nazar aata hai.

---

## Sequence flow (aapke code ke hisab se)
boot/kernel.asm
```asm 
kernel_main:
    fork task_1

    mov cx, 0x100
    .p:
    mov al, 'M'
    mov ah, 0xe
    int 0x10
    loop .p

    fork task_2

    mov cx, 0x100
    .p1:
    mov al, 'M'
    mov ah, 0xe
    int 0x10
    loop .p1
    exit
```

---

## Summary (short)

ye setup **three-task** dynamic creation aur round-robin scheduling dikhata hai, isliye output waise hi cycle hota hai: `MMMM...1111...2222...MMMM...` — kyunki har task timer-based time slice share karta hai (100 Hz PIT). Kuch chhote fixes (specially `len_tasks` initialization aur `exit` handling) se behaviour zyada predictable aur robust ho jayega.