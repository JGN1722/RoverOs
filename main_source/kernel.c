#include "common.h"
#include "../kernel-c/low_level.c"
#include "../kernel-c/print_hex.c"

// Drivers
#include "../kernel-c/drivers/vga.c"
#include "../kernel-c/drivers/disk.c"

// Descriptor tables
#include "../kernel-c/gdt/gdt.c"
#include "../kernel-c/interrupts/interrupts.c"

// Memory
#include "../kernel-c/memory/pmm.c"
#include "../kernel-c/memory/vmm.c"
#include "../kernel-c/memory/kmalloc.c"

void init_component(char *msg, int (*fptr)(void)) {
	printf(" + %s", msg);
	int ret = fptr();
	
	if (ret) {
		set_terminal_color(COLOR(RED,BLACK));
		printf(" [ ERROR ]\n");
		set_terminal_color(COLOR(WHITE,BLACK));
		asm("hlt");
	} else {
		set_terminal_color(COLOR(GREEN,BLACK));
		printf(" [ OK ]\n");
		set_terminal_color(COLOR(WHITE,BLACK));
	}
}

int main() {
	init_vga();
	printf("Initializing the system...\n");
	
	init_component("Setting up Global Descriptor Table...", setup_gdt);
	init_component("Setting up interrupts...", setup_interrupts);
	init_component("Setting up memory...", setup_memory);
	
	PIC_mask(0xfd, 0xff); // Enable the keyboard only
	
	asm("sti");
	
	printf("all done, hanging\n");
	while (1) asm("hlt");
	
	return 0;
}
