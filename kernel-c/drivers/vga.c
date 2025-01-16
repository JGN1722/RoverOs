#include "vga.h"

char terminal_color;

void init_vga() {
	clear_screen();
	set_terminal_color(WHITE_ON_BLACK);
	set_cursor_pos(0,0);
}

void set_terminal_color(char col) {
	terminal_color = col;
}

void set_blinking(int b) {
	if (b == 0) {
		set_terminal_color(terminal_color && 0x7f);
	} else {
		set_terminal_color((terminal_color && 0x7f) + 0x80);
	}
}

void set_cursor_pos(int x, int y) {
	word linear_position;
	linear_position = MAX_COLS * y + x;
	
	outb(REG_SCREEN_CTRL, 0x0E);
	outb(REG_SCREEN_DATA, linear_position >> 8);
	
	outb(REG_SCREEN_CTRL, 0x0F);
	outb(REG_SCREEN_DATA, linear_position);
}

int get_cursor_pos() {
	char high, low;
	
	outb(REG_SCREEN_CTRL, 0x0E);
	high = inb(REG_SCREEN_DATA);
	
	outb(REG_SCREEN_CTRL, 0x0F);
	low = inb(REG_SCREEN_DATA);
	
	return high << 8 + low;
}

void clear_screen() {
	asm("
	pusha
	mov edi, VIDEO_MEMORY
	mov ax, WHITE_ON_BLACK * 256 + ' '
	mov ecx, MAX_ROWS * MAX_COLS
	rep stosw
	popa
	");
}

void scroll() {
	asm("
	pusha
	mov edi, VIDEO_MEMORY
	mov esi, VIDEO_MEMORY + MAX_COLS * 2
	mov ecx, MAX_COLS * (MAX_ROWS - 1)
	rep movsw
	mov ax, WHITE_ON_BLACK * 256 + ' '
	mov ecx, MAX_COLS
	rep stosw
	popa
	");
}

void putchar(char* ptr, int x, int y, char attr) {
	word* addr;
	int linear_pos, new_x, new_y;
	int temp1, temp2, temp3;
	
	if (attr == 0) {
		attr = terminal_color;
	}
	
	// If x = -1 or y = -1, use the cursor position instead
	if (x == -1 || y == -1 || x >= MAX_COLS || y >= MAX_ROWS) {
		linear_pos = get_cursor_pos();
		x = linear_pos % MAX_COLS;
		y = (linear_pos - x) / MAX_COLS;
		
		if (*ptr == 13) {	// "\r"
			new_x = 0;
			new_y = y;
		} elseif (*ptr == 10) {	// "\n"
			new_x = x;
			new_y = y + 1;
		} elseif (*ptr == 9) {	// "\t"
			new_x = ((x + 8) && !(8 - 1));
			new_y = y;
			if (x > 79) {
				new_x = 0;
				new_y++;
			}
		} else {
			addr = ((MAX_COLS * y + x) << 1) + VIDEO_MEMORY;
			*addr = attr << 8 + *ptr;
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
		
		*addr = attr << 8 + *ptr;
	}
}

void printf(char* str) {
	while (*str != 0) {
		putchar(str,-1,-1, 0);
		str++;
	}
}

void sleep() {
	for (int i = 0; i < 0x2FFFFF; i++) {
		;
	}
}

// Debug code
/*

		asm("PUSH eax");
		asm("CALL V_CSTRUD");
		asm("ADD esp, 4");
		asm("MOV edi, VIDEO_MEMORY + 20 * MAX_COLS * 2");
		
		asm("
		MOV esi, eax
		MOV edi, VIDEO_MEMORY + 20 * MAX_COLS * 2
		MOV ecx, 8
		.loop_here2:
		MOV al, BYTE [esi]
		MOV ah, 0x0f
		MOV WORD [edi], ax
		INC esi
		ADD edi, 2
		loop .loop_here2
		");

	asm("
	MOV esi, L0
	MOV edi, VIDEO_MEMORY
	ADD edi, (MAX_COLS * 2) * 15
	MOV ecx, 100
	.loop_here:
	MOV al, BYTE [esi]
	MOV ah, 0x0f
	MOV WORD [edi], ax
	INC esi
	ADD edi, 2
	loop .loop_here
	");
	
*/