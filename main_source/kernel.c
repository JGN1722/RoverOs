#include "common.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"

// Interrupts
#include "..\kernel-c\interrupts\interrupts.c"

// Memory
#include "..\kernel-c\memory\pmm.c"

// TODO: error handling
void init_component(char *msg, void (*fptr)(void)) {
	set_terminal_color(COLOR(WHITE,BLACK));
	printf(" + %s", msg);
	fptr();
	set_terminal_color(COLOR(GREEN,BLACK));
	printf(" [ OK ]\r\n");
	set_terminal_color(COLOR(WHITE,BLACK));
}

int main() {
	init_vga();
	printf("Initializing the system...\r\n");
	
	init_component("Setting up interrupts... ", setup_interrupts);
	init_component("Setting up memory...", setup_memory);
	
	printf("Testing memory:\r\n");
	enum_memory_map();
	
	uint8_t a = bitmap_get(0x2A);
	bitmap_set(0x2A, 1);
	uint8_t b = bitmap_get(0x2A);
	bitmap_set(0x2A, 1);
	uint8_t c = bitmap_get(0x2A);
	bitmap_set(0x2A, 0);
	uint8_t d = bitmap_get(0x2A);
	printf("should print 0? 01 01 00: %c %c %c %c\r\n", a, b, c, d);
	
	printf("should print 00001000 00000000: %d %d\r\n", palloc(), palloc());
	
	printf("should print 01 01: %c %c\r\n", bitmap_get(0x00), bitmap_get(0x01));
	pfree(0x00);
	pfree(PMM_BLOCK_SIZE);
	printf("should print 00 00: %c %c\r\n", bitmap_get(0x00), bitmap_get(0x01));
	
	PIC_mask(0xfd, 0xff); // Enable the keyboard only
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	while (1) asm("hlt");
	
	return 0;
}
