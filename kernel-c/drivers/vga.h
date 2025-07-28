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
void printf(char* fmt, ...);
void sleep();

#define VIDEO_MEMORY 0xB8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

#define COLOR(FRONT, BACK) (((BACK) << 4) + (FRONT))

#define BLACK 0b0000
#define WHITE 0b1111
#define RED   0b0100
#define GREEN 0b0010
#define BLUE  0b0001
#define BLINK 0b1000
#define LIGHT 0b1000

#endif