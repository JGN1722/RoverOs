#include "constants.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"
#include "..\kernel-c\drivers\keyboard.c"
#include "..\kernel-c\drivers\ps2.c"

// Memory
#include "..\kernel-c\memory\pmm.c"

// Interrupts
#include "..\kernel-c\interrupts\interrupts.c"
#include "..\kernel-c\interrupts\exceptions.c"
#include "..\kernel-c\interrupts\irqs.c"

int main() {
	asm("include '..\boot\constants.inc'"); // This is a temporary solution
	
	init_vga();
	
	printf("Initializing the system...\r\n");
	
	printf("Setting up memory...\r\n");
	sort_memory_map();
	enum_memory_map();
	fill_bitmap();
	
	printf("Setting up interrupts...\r\n");
	build_idt();
	install_generic_interrupt_handler();
	install_exception_interrupts();
	install_irq_interrupts();
	
	PIC_remap(MASTER_IRQ_VECTOR_OFFSET, SLAVE_IRQ_VECTOR_OFFSET);
	PIC_mask(0xfd, 0xff); /* Enable the keyboard only */
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	do {
		asm("hlt");
	}
}

int keyboard_handler() {
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
