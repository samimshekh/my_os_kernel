#pragma once
#include "type.h"
#include "stdio.h"

typedef struct regs {
    uint32_t gs, fs, es, ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t int_no, err_code;
    uint32_t eip, cs, eflags, useresp, ss;
} regs_t;

void isr_handler(regs_t *r)
{
    printf("Interrupt:\n DS=0x%x EAX=0x%x EBX=0x%x ECX=0x%x EDX=0x%x ESI=0x%x EDI=0x%x EBP=0x%x ESP=0x%x EIP=0x%x CS=0x%x SS=0x%x EFLAGS=0x%x INT=0x%x ERR=0x%x\n", r->ds, r->eax, r->ebx, r->ecx, r->edx, r->esi, r->edi, r->ebp, r->esp, r->eip, r->cs, r->ss, r->eflags, r->int_no, r->err_code);
}