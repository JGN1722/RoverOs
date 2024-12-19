void except_default() {
	asm("pushad");
	
	printf("Unhandled exception\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_null_div() {
	asm("pushad");
	
	printf("Division by 0\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_overflow() {
	asm("pushad");
	
	printf("Overflow\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_double_fault() {
	asm("pushad");
	
	printf("Double fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_ss_fault() {
	asm("pushad");
	
	printf("Stack segment fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_gpf() {
	asm("pushad");
	
	printf("General protection fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_page_fault() {
	asm("pushad");
	
	printf("Page fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void except_float() {
	asm("pushad");
	
	printf("Floating point exception\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

void install_exception_interrupts() {
	int i = 0;
	
	// First, install the default handler everywhere
	while (i < IDT_ERR_ENTRIES) {
		install_interrupt_handler(i, except_default);
		i++;
	}
	
	// Then, install the specific handlers
	install_interrupt_handler(0, except_null_div);
	install_interrupt_handler(4, except_overflow);
	install_interrupt_handler(8, except_double_fault);
	install_interrupt_handler(12, except_ss_fault);
	install_interrupt_handler(13, except_gpf);
	install_interrupt_handler(14, except_page_fault);
	install_interrupt_handler(16, except_float);
}