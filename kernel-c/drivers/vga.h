// #ifdef and #ifndef are not implemented yet
// I'll just stick to this

// Well, this compiler is a shitshow anyway

void init_vga();
void set_terminal_color(char col);
void set_blinking(int b);
void set_cursor_pos(int x, int y);
int get_cursor_pos();
void clear_screen();
void scroll();
void putchar(char* ptr, int x, int y, char attr);
void printf(char* str);
void sleep();