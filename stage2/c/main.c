#include "stdio.h"
#include "cpu/gdt.h"
#include "cpu/idt.h"

const char *text = "# 32-bit Protected Mode GDT Setup in c\n# idt Setup in c\n# test int/10 __asm__ volatile (\"int $0x10\");\n";

void main(short int d) {
    (void)d;
    Initialize_GDT();
    Initialize_Idt();
    setColor(LIGHT_GREEN, BLACK);
    cls();
    printf(text);
    __asm__ volatile ("int $0x10");
    printf("shell> ");
    /* halt loop */
    for (;;) __asm__ volatile ("hlt");
}