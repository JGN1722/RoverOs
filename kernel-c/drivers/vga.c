#include "vga.h"

uint8_t terminal_color = COLOR(WHITE, BLACK);
uint8_t cursor_x = 0, cursor_y = 0;

void init_vga() {
	clear_screen();
	set_terminal_color(COLOR(WHITE,BLACK));
	sync_cursor_pos();
}

void set_terminal_color(char col) {
	terminal_color = col;
}

void set_blinking(int b) {
	if (b == 0) set_terminal_color(terminal_color & 0x7f);
	else set_terminal_color(terminal_color | 0x80);
}

void sync_cursor_pos() {
	uint16_t linear_position = MAX_COLS * cursor_y + cursor_x;
	
	outb(REG_SCREEN_CTRL, 0x0E);
	outb(REG_SCREEN_DATA, linear_position >> 8);
	
	outb(REG_SCREEN_CTRL, 0x0F);
	outb(REG_SCREEN_DATA, linear_position);
}

void clear_screen() {
	for (uint16_t *ptr = VIDEO_MEMORY; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS; ptr += 2) {
		*ptr = (COLOR(WHITE, BLACK) << 8) + ' ';
	}
	sync_cursor_pos();
}

void scroll() {
	for (uint16_t *ptr = VIDEO_MEMORY; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS - 2 * MAX_COLS; ptr += 2) {
		*ptr = *((uint16_t *)(ptr + 2 * MAX_COLS));
	}
	for (; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS; ptr += 2) {
		*ptr = (COLOR(WHITE, BLACK) << 8) + ' ';
	}
	cursor_y--;
	if (cursor_y == 255) cursor_y = 0; // uints wrap instead of going negative
	sync_cursor_pos();
}

void putchar(char* ptr, uint32_t x, uint32_t y, uint8_t attr) {
	uint16_t* addr;
	uint8_t new_x, new_y;
	
	if (attr == 0) attr = terminal_color;
	
	// If x = -1 or y = -1, use the cursor position instead
	if (x == -1 || y == -1 || x >= MAX_COLS || y >= MAX_ROWS) {
		
		switch(*ptr) {
			case '\r':
				new_x = 0;
				new_y = cursor_y;
				break;
			case '\n':
				new_x = cursor_x;
				new_y = cursor_y + 1;
				break;
			case '	':
				new_x = (cursor_x + 8) & ~(8 - 1);
				new_y = cursor_y;
				if (cursor_x > 79) {
					new_x = 0;
					new_y++;
				}
				break;
			default:
				addr = ((MAX_COLS * cursor_y + cursor_x) << 1) + VIDEO_MEMORY;
				*addr = (attr << 8) + *ptr;
				if (cursor_x < 79) {
					new_x = cursor_x + 1;
					new_y = cursor_y;
				} else {
					new_x = 0;
					new_y = cursor_y + 1;
				}
		}
		if (new_y >= MAX_ROWS) {
			new_y--;
			scroll();
		}
		
		cursor_x = new_x;
		cursor_y = new_y;
		sync_cursor_pos();
	} else {
		addr = ((MAX_COLS * y + x) << 1) + VIDEO_MEMORY;
		
		*addr = (attr << 8) + *ptr;
	}
}

void printf(const char* fmt, ...) {
	int i = 1;
	while (*fmt != 0) {
		if (*fmt == '%') {
			fmt++;
			switch (*fmt) {
				case 'd':
					printf(cstrud(VA_ARG(fmt, i, int)));
					break;
				case 'c':
					printf(cstrub(VA_ARG(fmt, i, char)));
					break;
				case 's':
					printf(VA_ARG(fmt, i, char *));
					break;
				default:
					putchar(fmt - 1, -1, -1, 0);
					putchar(fmt, -1, -1, 0);
					i--; // better than i++ everywhere else
			}
			i++;
		} else {
			if (*fmt == '\n') {
				putchar("\r", -1, -1, 0);
				putchar("\n", -1, -1, 0);
			} else {
				putchar(fmt, -1, -1, 0);
			}
		}
		fmt++;
	}
}
