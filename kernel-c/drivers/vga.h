#ifndef _VGA_H
#define _VGA_H

void init_vga();
void set_terminal_color(char col);
void set_blinking(int b);
void set_cursor_pos(uint32_t x, uint32_t y);
uint32_t get_cursor_pos();
void clear_screen();
void scroll();
void putchar(char* ptr, uint32_t x, uint32_t y, uint8_t attr);
void printf(char* str);
void sleep();

#endif