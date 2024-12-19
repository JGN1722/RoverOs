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

void install_irq_interrupts() {
	int i = MASTER_IRQ_VECTOR_OFFSET;
	
	// Install the default handler everywhere
	while (i < MASTER_IRQ_VECTOR_OFFSET + 8) {
		install_interrupt_handler(i, master_irq_default);
		i++;
	}
	i = SLAVE_IRQ_VECTOR_OFFSET;
	while (i < SLAVE_IRQ_VECTOR_OFFSET + 8) {
		install_interrupt_handler(i, slave_irq_default);
		i++;
	}
	
	// Install keyboard interrupt handler
	install_interrupt_handler(MASTER_IRQ_VECTOR_OFFSET + 1, keyboard_handler);
}