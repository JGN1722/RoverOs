[[roverc::interrupt]] void except_default() {      printf("Unhandled exception\n");}
[[roverc::interrupt]] void except_null_div() {     printf("Division by 0\n");}
[[roverc::interrupt]] void except_overflow() {     printf("Overflow\n");}
[[roverc::interrupt]] void except_double_fault() { printf("Double fault\n");}
[[roverc::interrupt]] void except_ss_fault() {     printf("Stack segment fault\n");}
[[roverc::interrupt]] void except_gpf() {          printf("General protection fault\n");}
[[roverc::interrupt]] void except_page_fault() {   printf("Page fault\n");}
[[roverc::interrupt]] void except_float() {        printf("Floating point exception\n");}

void install_exception_interrupts() {
	// First, install the default handler everywhere
	for (int i = 0; i < IDT_ERR_ENTRIES; i++) {
		install_interrupt_handler(i, except_default);
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