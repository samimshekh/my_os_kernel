#include "stdio.h"
#include "cpu/gdt.h"
#include "cpu/idt.h"
#include "cpu/i8259.h"

const char *text = "[INFO] 32-bit Protected Mode GDT Setup in c\n"
                   "[INFO] idt Setup in c\n"
                   "[INFO] Reinitialize i8259 0x20, 0x28\n"
                   "[INFO] test int/10 __asm__ volatile (\"int $0x10\");\n";

void main(short int d) {
    (void)d;
    Initialize_GDT();
    Initialize_Idt();
    Initialize_i8259(0x20, 0x28, false);
    setColor(LIGHT_GREEN, BLACK);
    cls();
    printf(text);
    __asm__ volatile ("int $0x10");
    printf("shell> ");
    /* halt loop */
    for (;;) __asm__ volatile ("hlt");
}