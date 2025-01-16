#include "constants.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"

// Memory
#include "..\kernel-c\memory\pmm.c"

// Interrupts
#include "..\kernel-c\interrupts\interrupts.c"
#include "..\kernel-c\interrupts\exceptions.c"
#include "..\kernel-c\interrupts\irqs.c"

int main() {
	asm("include '..\main_source\constants.asm'"); // This is a temporary solution
	
	init_vga();
	
	printf("Initializing the system...\r\n");
	
	printf("Setting up memory...\r\n"); // Enumerate memory map and initialize bitmap
	enum_memory_map();
	fill_bitmap();

	// Example usage
	void* block = allocate_block();
	if (block) {
		printf("Allocated block at: %p\n", block);
	} else {
		printf("No free memory blocks available.\n");
	}

	free_block(block);
	printf("Block freed: %p\n", block);
	
	printf("Setting up interrupts...\r\n");
	build_idt();
	install_generic_interrupt_handler();
	install_exception_interrupts();
	install_irq_interrupts();
	
	PIC_remap(MASTER_IRQ_VECTOR_OFFSET, SLAVE_IRQ_VECTOR_OFFSET);
	PIC_mask(0xfd, 0xff); /* Enable the keyboard only */
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	while (1) {
		asm("hlt");
	}
	
	return 0;
}

void keyboard_handler() {
	asm("pushad");
	printf("Key pressed! ");
	
	// For now, read and discard the key scan code
	printf("Key code: ");
	printf(cstrub(inb(0x60)));
	printf("\r\n");
	
	outb(PIC1_COMMAND, PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}