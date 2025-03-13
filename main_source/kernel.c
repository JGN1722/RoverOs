#include "constants.h"
#include "..\kernel-c\low_level.c"
#include "..\kernel-c\print_hex.c"

// Drivers
#include "..\kernel-c\drivers\vga.c"

// Interrupts
#include "..\kernel-c\interrupts\interrupts.c"
#include "..\kernel-c\interrupts\exceptions.c"
#include "..\kernel-c\interrupts\irqs.c"

#define max(A,B) ((A) > (B) : (A) ? (B))
#define min(A,B) ((A) < (B) : (A) ? (B))

int main(void) {
	// Temporary workaround
	asm("include '..\main_source\constants.asm'");
	
	init_vga();
	printf("Initializing the system...\r\n");
	
	printf("Setting up interrupts...\r\n");
	build_idt();
	install_generic_interrupt_handler();
	install_exception_interrupts();
	install_irq_interrupts();
	
	PIC_remap(MASTER_IRQ_VECTOR_OFFSET, SLAVE_IRQ_VECTOR_OFFSET);
	PIC_mask(0xfd, 0xff); // Enable the keyboard only
	
	asm("sti");
	
	set_terminal_color(0x1f);
	set_blinking(1);
	printf("This should blink\r\n");
	set_blinking(0);
	printf("This shouldn't\r\n");
	
	printf("all done, hanging\r\n");
	
	printf("here is the max between 2 and 4: ");
	printf(cstrub(max(1 + 1, 2 + 2)));
	printf("\r\n");
	
	while (1) {
		asm("hlt");
	}
	
	return 0;
}
