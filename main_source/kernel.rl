include "constants.inc"
include "..\kernel\low_level.rl"
include "..\kernel\print_hex.rl"

\ Drivers \
include "..\kernel\drivers\vga.rl"
include "..\kernel\drivers\keyboard.rl"
include "..\kernel\drivers\ps2.rl"

\ Memory \
include "..\kernel\memory\pmm.rl"

\ Interrupts \
include "..\kernel\interrupts\interrupts.rl"
include "..\kernel\interrupts\exceptions.rl"
include "..\kernel\interrupts\irqs.rl"

int main() {
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
	
	PIC_remap(#MASTER_IRQ_VECTOR_OFFSET, #SLAVE_IRQ_VECTOR_OFFSET);
	PIC_mask(0xfd, 0xff); \ Enable the keyboard only \
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	do {
		asm("hlt");
	}
}

int keyboard_handler() {
	asm("pushad");
	printf("Key pressed! ");
	
	\ For now, read and discard the key scan code \
	printf("Key code: ");
	printf(cstrub(inb(0x60)));
	printf("\r\n");
	
	outb(#PIC1_COMMAND, #PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}
