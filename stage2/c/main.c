#include "stdio.h"
const char *text = "                                                                                "
"                                  my_os_kernel                                  "
"                                                                                "
"                                                                                "
"  #### #####  ###  ####  #####       #   # #   #        ###   ####              "
" #       #   #   # #   #   #         ## ## #   #       #   # #                  "
" #       #   #   # #   #   #         # # #  # #        #   # #                  "
"  ###    #   ##### ####    #         # # #   #         #   #  ###               "
"     #   #   #   # # #     #         #   #   #         #   #     #              "
"     #   #   #   # #  #    #         #   #   #         #   #     #   ## ## ##   "
" ####    #   #   # #   #   #         #   #   #          ###  ####    ## ## ##   "
"                                                                                "
"                      My OS Kernel - Bootloader (x86 i686)                      "
"                                                                                "
"                                                                                "
"Architecture:                                                                   "
"________________________________________________________________________________"
"                                                                                "
".   Target Architecture: x86 i686 (32-bit)                                      "
".   Boot Mode: BIOS (Real Mode)                                                 "
".   Boot Sector Size: 512 bytes                                                 "
".   Boot Signature: 0x55AA (mandatory for BIOS recognition)                     "
"                                                                                "
"                                                                                "
"                                                                                ";

void main(short int d) {
    (void)d;
    setColor(LIGHT_GREEN, BLACK);
    cls();
    printf(text);
    /* halt loop */
    for (;;) __asm__ volatile ("hlt");
}