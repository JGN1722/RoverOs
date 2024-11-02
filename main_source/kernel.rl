include "constants.inc"
include "..\kernel\low_level.rl"

\ Drivers \
include "..\kernel\drivers\vga.rl"
include "..\kernel\drivers\keyboard.rl"
include "..\kernel\drivers\ps2.rl"

\ Interrupts \
include "..\kernel\interrupts\interrupts.rl"
include "..\kernel\interrupts\exceptions.rl"
include "..\kernel\interrupts\irqs.rl"\

int main() {
	init_vga();
	printf("Initializing the system...\r\n");
	
	printf("Setting up interrupts...\r\n");
	\build_idt();
	install_generic_interrupt_handler();
	install_exception_interrupts();
	install_irq_interrupts();\
	
	\PIC_remap(#MASTER_IRQ_VECTOR_OFFSET, #SLAVE_IRQ_VECTOR_OFFSET);\
	\PIC_mask(0xfd, 0xff);\ \ Enable the keyboard only \
	
	\asm("sti");\
	
	set_terminal_color(0x1f);
	set_blinking(1);
	printf("This should blink\r\n");
	set_blinking(0);
	printf("This shouldn't\r\n");
	
	printf("all done, hanging\r\n");
	do {
		asm("hlt");
	}
}

int keyboard_handler() {
	asm("pushad");
	printf("Key pressed!\r\n");
	
	\ For now, read and discard the key scan code \
	inb(0x60);
	
	outb(#PIC1_COMMAND, #PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}
