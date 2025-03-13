[[roverc::interrupt]] void master_irq_default() {
	printf("Unhandled IRQ received\r\n");
	
	outb(PIC1_COMMAND, PIC_EOI);
	
}

[[roverc::interrupt]] void slave_irq_default() {
	printf("Unhandled IRQ received\r\n");
	
	outb(PIC2_COMMAND, PIC_EOI);
	outb(PIC1_COMMAND, PIC_EOI);
}

// [[roverc::interrupt]] void keyboard_handler() {
void keyboard_handler() __attribute__((roverc::interrupt)) {
	uint8_t key_code = inb(0x60);
	
	set_terminal_color(key_code);
	printf("Key pressed!\r\n");
	
	// For now, read and discard the key scan code
	printf("Key code: ");
	printf(cstrub(key_code));
	printf("\r\n");
	
	outb(PIC1_COMMAND, PIC_EOI);
}

void install_irq_interrupts() {
	// Install the default handler everywhere
	for (int i = MASTER_IRQ_VECTOR_OFFSET; i < MASTER_IRQ_VECTOR_OFFSET + 8; i++) {
		install_interrupt_handler(i, master_irq_default);
	}
	for (i = SLAVE_IRQ_VECTOR_OFFSET; i < SLAVE_IRQ_VECTOR_OFFSET + 8; i++) {
		install_interrupt_handler(i, slave_irq_default);
	}
	
	// Install keyboard interrupt handler
	install_interrupt_handler(MASTER_IRQ_VECTOR_OFFSET + 1, keyboard_handler);
}