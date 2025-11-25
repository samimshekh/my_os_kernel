#pragma once
#include "type.h"
#include <stdarg.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_TEXT_BUFFER ((volatile uint16_t*)0xB8000)
#define BLACK         0x0
#define BLUE          0x1
#define GREEN         0x2
#define CYAN          0x3
#define RED           0x4
#define MAGENTA       0x5
#define BROWN         0x6
#define LIGHT_GRAY    0x7
#define DARK_GRAY     0x8
#define LIGHT_BLUE    0x9
#define LIGHT_GREEN   0xA
#define LIGHT_CYAN    0xB
#define LIGHT_RED     0xC
#define LIGHT_MAGENTA 0xD
#define YELLOW        0xE
#define WHITE         0xF
#define VGA_COLOR(fg, bg) ((bg << 4) | (fg))

int x = 0, y = 0;
uint8_t attr = VGA_COLOR(WHITE, BLACK);

void setXY(int nx, int ny)
{
    x = nx;
    y = ny;
}

void setColor(uint8_t fg, uint8_t bg)
{
    attr = VGA_COLOR(fg, bg);
}


static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline uint16_t make_vga_entry(char c, uint8_t attr) {
    return (uint16_t)c | ((uint16_t)attr << 8);
}

// set hardware text-mode cursor to (x,y)
void set_cursor() {
    uint16_t pos = (uint16_t)(y * VGA_WIDTH + x);

    outb(0x3D4, 14);               // select high cursor byte
    outb(0x3D5, (uint8_t)(pos >> 8));
    outb(0x3D4, 15);               // select low cursor byte
    outb(0x3D5, (uint8_t)(pos & 0xFF));
}

// put single char at x,y with attribute (no scrolling)
void put_char_at(char c) {
    if (c == '\n') 
    {
        x = 0;
        y += 1;
        return;
    }

    if (y >= VGA_HEIGHT)
    {
        for (int i = 0; i < (VGA_HEIGHT * VGA_WIDTH); i++)
        {
           if (i < ((VGA_HEIGHT -1) * VGA_WIDTH))
           {
                VGA_TEXT_BUFFER[(uint16_t)i] = VGA_TEXT_BUFFER[(uint16_t)(i + VGA_WIDTH)];
           }else VGA_TEXT_BUFFER[(uint16_t)i] = make_vga_entry(' ', attr);
        }
        
        x =0;
        y--;
    }

    uint16_t idx = (uint16_t)(y * VGA_WIDTH + x);
    VGA_TEXT_BUFFER[idx] = make_vga_entry(c, attr);
    x++;
    
    if (x >= VGA_WIDTH) 
    {
        x  = 0;
        y += 1;
    }
    
}

// convenience: print a nul-terminated string starting at x,y (no wrap handling)
void print_string_at(const char *s) {
    while (*s) {
        put_char_at(*s++);
    }
}

void h8(uint8_t v)
{
    put_char_at((v >> 4 & 0xF) + ((v >> 4 & 0xF) < 10 ? '0' : 'A' - 10));
    put_char_at((v & 0xF) + ((v & 0xF) < 10 ? '0' : 'A' - 10));
    set_cursor();
}


void h16(uint16_t value)
{
    h8((uint8_t)((value >> 8) & 0xFF));
    h8((uint8_t)(value & 0xFF));
}

void h32(uint32_t value)
{
    h16((uint16_t)((value >> 16) & 0xFFFF));
    h16((uint16_t)(value & 0xFFFF));
}

void cls()
{
    x = 0;
    y = 0;
    for (int i = 0; i < (25 * 80); i++)
    {
        VGA_TEXT_BUFFER[(uint16_t)i] = make_vga_entry(' ', attr);
    }
    set_cursor(); // move cursor to after last printed char
}

void printf(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    for (; *format; format++) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 'c': 
                    put_char_at((char)va_arg(args, int));
                    break;
                case 's': 
                    print_string_at(va_arg(args, const char*)); 
                    break;
                case 'x': h32(va_arg(args, uint32_t)); break;
                case 'w': h16((uint16_t)va_arg(args, int)); break;
                case 'b': h8((uint8_t)va_arg(args, int)); break;
                default:  put_char_at('%'); put_char_at(*format); break;
            }
        } else {
            put_char_at(*format);
        }

    }

    va_end(args);
    
    set_cursor(); // move cursor to after last printed char

}

