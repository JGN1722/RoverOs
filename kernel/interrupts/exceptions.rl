int except_default() {
	asm("pushad");
	
	printf("Unhandled exception\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_null_div() {
	asm("pushad");
	
	printf("Division by 0\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_overflow() {
	asm("pushad");
	
	printf("Overflow\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_double_fault() {
	asm("pushad");
	
	printf("Double fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_ss_fault() {
	asm("pushad");
	
	printf("Stack segment fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_gpf() {
	asm("pushad");
	
	printf("General protection fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_page_fault() {
	asm("pushad");
	
	printf("Page fault\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int except_float() {
	asm("pushad");
	
	printf("Floating point exception\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int install_exception_interrupts() {
	int i;
	
	\ First, install the default handler everywhere \
	i = 0;
	while i < #IDT_ERR_ENTRIES {
		install_interrupt_handler(i, @except_default);
		i++;
	}
	
	\ Then, install the specific handlers \
	install_interrupt_handler(0, @except_null_div);
	install_interrupt_handler(4, @except_overflow);
	install_interrupt_handler(8, @except_double_fault);
	install_interrupt_handler(12, @except_ss_fault);
	install_interrupt_handler(13, @except_gpf);
	install_interrupt_handler(14, @except_page_fault);
	install_interrupt_handler(16, @except_float);
}