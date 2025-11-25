#include "stdio.h"
#include "cpu/gdt.h"

const char *text = "# 32-bit Protected Mode GDT Setup in c\nshall> ";

void main(short int d) {
    (void)d;
    Initialize_GDT();
    setColor(LIGHT_GREEN, BLACK);
    cls();
    printf(text);
    /* halt loop */
    for (;;) __asm__ volatile ("hlt");
}