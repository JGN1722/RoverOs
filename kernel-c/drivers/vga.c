#include "vga.h"

uint8_t terminal_color = COLOR(WHITE, BLACK);

void init_vga() {
	clear_screen();
	set_terminal_color(COLOR(WHITE,BLACK));
}

void set_terminal_color(char col) {
	terminal_color = col;
}

void set_blinking(int b) {
	if (b == 0) set_terminal_color(terminal_color & 0x7f);
	else set_terminal_color((terminal_color & 0x7f) + 0x80);
}

void set_cursor_pos(uint32_t x, uint32_t y) {
	uint16_t linear_position = MAX_COLS * y + x;
	
	outb(REG_SCREEN_CTRL, 0x0E);
	outb(REG_SCREEN_DATA, linear_position >> 8);
	
	outb(REG_SCREEN_CTRL, 0x0F);
	outb(REG_SCREEN_DATA, linear_position);
}

uint32_t get_cursor_pos() {
	uint8_t high, low;
	
	outb(REG_SCREEN_CTRL, 0x0E);
	high = inb(REG_SCREEN_DATA);
	
	outb(REG_SCREEN_CTRL, 0x0F);
	low = inb(REG_SCREEN_DATA);
	
	return (high << 8) + low;
}

void clear_screen() {
	for (uint16_t *ptr = VIDEO_MEMORY; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS; ptr += 2) {
		*ptr = (COLOR(WHITE, BLACK) << 8) + ' ';
	}
	set_cursor_pos(0,0);
}

void scroll() { // TODO: should update cursor pos
	uint16_t *ptr = VIDEO_MEMORY;
	for (; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS - 2 * MAX_COLS; ptr += 2) {
		*ptr = *((uint16_t *)(ptr + 2 * MAX_COLS));
	}
	for (; ptr < VIDEO_MEMORY + 2 * MAX_ROWS * MAX_COLS; ptr += 2) {
		*ptr = (COLOR(WHITE, BLACK) << 8) + ' ';
	}
}

void putchar(char* ptr, uint32_t x, uint32_t y, uint8_t attr) {
	uint16_t* addr;
	uint32_t linear_pos, new_x, new_y;
	
	if (attr == 0) attr = terminal_color;
	
	// If x = -1 or y = -1, use the cursor position instead
	if (x == -1 || y == -1 || x >= MAX_COLS || y >= MAX_ROWS) {
		linear_pos = get_cursor_pos();
		x = linear_pos % MAX_COLS;
		y = (linear_pos - x) / MAX_COLS;
		
		switch(*ptr) {
			case '\r':
				new_x = 0;
				new_y = y;
				break;
			case '\n':
				new_x = x;
				new_y = y + 1;
				break;
			case '	':
				new_x = (x + 8) & ~(8 - 1);
				new_y = y;
				if (x > 79) {
					new_x = 0;
					new_y++;
				}
				break;
			default:
				addr = ((MAX_COLS * y + x) << 1) + VIDEO_MEMORY;
				*addr = (attr << 8) + *ptr;
				if (x < 79) {
					new_x = x + 1;
					new_y = y;
				} else {
					new_x = 0;
					new_y = y + 1;
				}
		}
		if (new_y >= MAX_ROWS) {
			new_y--;
			scroll();
		}
		
		set_cursor_pos(new_x, new_y);
	} else {
		addr = ((MAX_COLS * y + x) << 1) + VIDEO_MEMORY;
		
		*addr = (attr << 8) + *ptr;
	}
}

void printf(char* fmt, ...) {
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
			putchar(fmt, -1, -1, 0);
		}
		fmt++;
	}
}

void sleep() {
	for (int i = 0; i < 0x2FFFFF; i++);
}
