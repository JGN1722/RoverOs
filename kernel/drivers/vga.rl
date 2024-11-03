global int terminal_color;

int init_vga() {
	clear_screen();
	set_terminal_color(0x0f);
	set_cursor_pos(0,0);
}

int set_terminal_color(int col) {
	terminal_color = col;
}

int set_blinking(int b) {
	if b = 0 {
		set_terminal_color(terminal_color & 0x7f);
	} else {
		set_terminal_color((terminal_color & 0x7f) + 0x80);
	}
}

int set_cursor_pos(int x, int y) {
	int linear_position;
	linear_position = #MAX_COLS * y + x;
	
	outb(#REG_SCREEN_CTRL, 0x0E);
	outb(#REG_SCREEN_DATA, (linear_position SHR 8));
	
	outb(#REG_SCREEN_CTRL, 0x0F);
	outb(#REG_SCREEN_DATA, linear_position);
}

int get_cursor_pos() {
	int high, low;
	
	outb(#REG_SCREEN_CTRL, 0x0E);
	high = inb(#REG_SCREEN_DATA);
	
	outb(#REG_SCREEN_CTRL, 0x0F);
	low = inb(#REG_SCREEN_DATA);
	
	return(high SHL 8 + low);
}

int clear_screen() {
	asm("
	pusha
	mov edi, VIDEO_MEMORY
	mov ax, 0x0f * 256 + ' '
	mov ecx, MAX_ROWS * MAX_COLS
	rep stosw
	popa
	");
}

int scroll() {
	asm("
	pusha
	mov edi, VIDEO_MEMORY
	mov esi, VIDEO_MEMORY + MAX_COLS * 2
	mov ecx, MAX_COLS * (MAX_ROWS - 1)
	rep movsw
	mov ax, 0x0F20
	mov ecx, MAX_COLS
	rep stosw
	popa
	");
}

int putchar(int ptr, int x, int y, int attr) {
	int linear_pos, addr;
	int new_x, new_y;
	
	if attr = 0 {
		attr = terminal_color;
	}
	
	\ If x = -1 or y = -1, use the cursor position instead \
	if x = -1 or y = -1 {
		linear_pos = get_cursor_pos();
		x = linear_pos % #MAX_COLS;
		y = (linear_pos - x) / #MAX_COLS;
		
		if BYTE *ptr = 13 {	"\r"
			new_x = 0;
			new_y = y;
		} elseif BYTE *ptr = 10 {	"\n"
			new_x = x;
			new_y = y + 1;
		} else {
			addr = ((#MAX_COLS * y + x) SHL 1) + #VIDEO_MEMORY;
			WORD *addr = attr SHL 8 + BYTE *ptr;
			if x < 79 {
				new_x = x + 1;
				new_y = y;
			} else {
				new_x = 0;
				new_y = y + 1;
			}
		}
		if new_y >= #MAX_ROWS {
			new_y -= 1;
			scroll();
		}
		set_cursor_pos(new_x, new_y);
	} else {
		addr = ((#MAX_COLS * y + x) SHL 1) + #VIDEO_MEMORY;
		
		WORD *addr = attr SHL 8 + BYTE *ptr;
	}
}

int printf(int str) {
	while BYTE *str <> 0 {
		putchar(str,-1,-1, 0);
		str++;
	}
}

int sleep() {int i;i = 0;while i < 0xFFFFF {i++;}}
