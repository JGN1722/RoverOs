void master_irq_default() {
	asm("pushad");
	
	printf("Unhandled IRQ received\r\n");
	
	outb(PIC1_COMMAND, PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void slave_irq_default() {
	asm("pushad");
	
	printf("Unhandled IRQ received\r\n");
	
	outb(PIC2_COMMAND, PIC_EOI);
	outb(PIC1_COMMAND, PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void keyboard_handler() {
	asm("pushad");
	printf("Key pressed!\r\n");
	
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