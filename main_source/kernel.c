#include "common.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"

// Descriptor tables
#include "..\kernel-c\gdt\gdt.c"
#include "..\kernel-c\interrupts\interrupts.c"

// Memory
#include "..\kernel-c\memory\pmm.c"
#include "..\kernel-c\memory\vmm.c"

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
	
	init_component("Setting up Global Descriptor Table... ", setup_gdt);
	init_component("Setting up interrupts... ", setup_interrupts);
	init_component("Setting up memory...", setup_memory);
	init_component("Setting up virtual memory...", setup_vmemory);
	
	PIC_mask(0xfd, 0xff); // Enable the keyboard only
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	while (1) asm("hlt");
	
	return 0;
}
