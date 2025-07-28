#include "common.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"

// Interrupts
#include "..\kernel-c\interrupts\interrupts.c"

#define max(A,B) ((A) > (B) : (A) ? (B))
#define min(A,B) ((A) < (B) : (A) ? (B))

void init_component(char *msg, void (*fptr)(void)) {
	set_terminal_color(COLOR(WHITE,BLACK));
	printf(" + %s ", msg);
	fptr();
	set_terminal_color(COLOR(GREEN,BLACK));
	printf("[ OK ]\r\n");
	set_terminal_color(COLOR(WHITE,BLACK));
}

int main(void) {
	init_vga();
	printf("Initializing the system...\r\n");
	
	init_component("Setting up interrupts... ", setup_interrupts);
	
	PIC_mask(0xfd, 0xff); // Enable the keyboard only
	
	asm("sti");
	
	set_terminal_color(0x1f);
	set_blinking(1);
	printf("This should blink\r\n");
	set_blinking(0);
	printf("This shouldn't\r\n");
	
	printf("here is the max between 2 and 4: %c\r\n", max(1 + 1, 2 + 2));
	
	printf("all done, hanging\r\n");
	while (1) asm("hlt");
	
	return 0;
}
