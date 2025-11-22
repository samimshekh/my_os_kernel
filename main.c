void main(short int d) {
    (void)d;
    char *vga = (char*)0xB8000;   // VGA text buffer start

    const char *msg = "Hello from C code...";
    int i = 0;

    while (msg[i] != '\0') {
        vga[i * 2] = msg[i];   // character
        vga[i * 2 + 1] = 0x0F; // color: Light gray on black
        i++;
    }

    /* halt loop */
    for (;;) __asm__ volatile ("hlt");
}
