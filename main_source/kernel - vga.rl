include "constants.inc"
include "..\kernel\low_level.rl"

\ Drivers \
include "..\kernel\drivers\vga.rl"

int main() {
	init_vga();
	printf("Initializing the system...\r\n");
	
	set_terminal_color(0x1f);
	set_blinking(1);
	printf("This should blink\r\n");
	set_blinking(0);
	printf("This shouldn't\r\n");
	
	printf("all done, hanging\r\n");
	putchar("x",1,1,0);
	
	do {
		asm("hlt");
	}
}
