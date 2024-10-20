include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\main_source\constants.inc"
include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\kernel\io\vga_driver.rl"

int main() {
	int i;
	
	clear_screen();
	set_cursor_pos(0,0);
	printf("Initializing system...\r\n");
	
	printf("Setting up IDT...\r\n");
	build_idt();
	
	i = 0;
	while i < #IDT_ERR_ENTRIES {
		install_interrupt_handler(i, @error_interrupt_handler);
		i++;
	}
	while i < #IDT_ERR_ENTRIES + #IRQ_NUMBER {
		install_interrupt_handler(i, @irq_handler);
		i++;
	}
	while i < #IDT_ENTRIES {
		install_interrupt_handler(i, @generic_interrupt_handler);
		i++;
	}
		
	PIC_remap(#IRQ_VECTOR_OFFSET, #IRQ_VECTOR_OFFSET + 8);
	disable_rtc();
	
	\ Enable the keyboard only \
	outb(#PIC1_DATA,0xfd);
	outb(#PIC2_DATA,0xff);
		
	\ Install the interrupt \
	install_interrupt_handler(#IRQ_VECTOR_OFFSET + 1, @keyboard_handler);
	
	asm("sti");
	
	printf("all done, hanging\r\n");
	do {
		asm("hlt");
	}
}

int disable_rtc() {
	int prev;
	
	outb(0x70, 0x8B);
	prev = inb(0x71);
	outb(0x70, 0x8B);
	outb(0x71, prev & 0x7F);
}

int PIC_remap(int offset1, int offset2) {
	int mask1, mask2;
	
	\ Save masks \
	mask1 = inb(#PIC1_DATA);
	mask2 = inb(#PIC2_DATA);
	
	\ Start cascade initialisation \
	outb(#PIC1_COMMAND, #ICW1_INIT | #ICW1_ICW4);
	outb(#PIC2_COMMAND, #ICW1_INIT | #ICW1_ICW4);
	
	\ Set PICs vector offset \
	outb(#PIC1_DATA, offset1);
	outb(#PIC2_DATA, offset2);
	
	\ Tell master PIC that there is a slave at IRQ2 (0000 0100) \
	outb(#PIC1_DATA, 4);
	\ Tell slave PIC its identity (0000 0010) \
	outb(#PIC2_DATA, 2);
	
	\ Have the PICs use 8086 mode instead of 8080 \
	outb(#PIC1_DATA, #ICW4_8086);
	outb(#PIC2_DATA, #ICW4_8086);
	
	\ Restore the masks \
	outb(#PIC1_DATA, mask1);
	outb(#PIC2_DATA, mask2);
}

int error_interrupt_handler(int interrupt_number) {
	asm("pushad");
	
	if interrupt_number = 0 {
		printf("division by 0\r\n");
	} elseif interrupt_number = 1 {
		printf("single-step interrupt\r\n");
	} elseif interrupt_number = 2 {
		printf("non-maskable interrupt\r\n");
	} elseif interrupt_number = 3 {
		printf("breakpoint\r\n");
	} elseif interrupt_number = 4 {
		printf("overflow\r\n");
	} elseif interrupt_number = 5 {
		printf("bound range exceeded\r\n");
	} elseif interrupt_number = 6 {
		printf("invalid opcode\r\n");
	} elseif interrupt_number = 7 {
		printf("coprocessor not available\r\n");
	} elseif interrupt_number = 8 {
		printf("double fault\r\n");
	} elseif interrupt_number = 9 {
		printf("coprocessor segment overrun\r\n");
	} elseif interrupt_number = 10 {
		printf("invalid task segment\r\n");
	} elseif interrupt_number = 11 {
		printf("segment not present\r\n");
	} elseif interrupt_number = 12 {
		printf("stack segment fault\r\n");
	} elseif interrupt_number = 13 {
		printf("general protection fault\r\n");
	} elseif interrupt_number = 14 {
		printf("page fault\r\n");
	} elseif interrupt_number = 15 {
		printf("reserved interrupt - should not happen\r\n");
	} elseif interrupt_number = 16 {
		printf("floating point exception\r\n");
	} elseif interrupt_number = 17 {
		printf("alignement check\r\n");
	} elseif interrupt_number = 18 {
		printf("machine check\r\n");
	} elseif interrupt_number = 18 {
		printf("SIMD floating point exception\r\n");
	} elseif interrupt_number = 19 {
		printf("virtualization exception\r\n");
	} elseif interrupt_number = 20 {
		printf("control protection exception - should not happen\r\n");
	} else {
		printf("reserved interrupt - should not happen\r\n");
	}
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int irq_handler(int interrupt_number) {
	asm("pushad");
	
	if interrupt_number = 0 {
		printf("IRQ 0 received\r\n");
	} elseif interrupt_number = 1 {
		printf("IRQ 1 received\r\n");
	} elseif interrupt_number = 2 {
		printf("IRQ 2 received\r\n");
	} elseif interrupt_number = 3 {
		printf("IRQ 3 received\r\n");
	} elseif interrupt_number = 4 {
		printf("IRQ 4 received\r\n");
	} elseif interrupt_number = 5 {
		printf("IRQ 5 received\r\n");
	} elseif interrupt_number = 6 {
		printf("IRQ 6 received\r\n");
	} elseif interrupt_number = 7 {
		printf("IRQ 7 received\r\n");
	} elseif interrupt_number = 8 {
		printf("8");
	} elseif interrupt_number = 9 {
		printf("IRQ 9 received\r\n");
	} else {
		printf("IRQ received\r\n");
	}
	
	if interrupt_number >= #IRQ_VECTOR_OFFSET + 8 {
		outb(#PIC2_COMMAND, #PIC_EOI);
	}
	outb(#PIC1_COMMAND, #PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int generic_interrupt_handler(int interrupt_number) {
	asm("pushad");
	
	printf("generic interrupt received\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int keyboard_handler() {
	asm("pushad");
	printf("Key pressed!\r\n");
	
	outb(#PIC1_DATA, #PIC_EOI);
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int install_interrupt_handler(int i, int ptr) {
	asm("
	mov edi, DWORD [ebp + 12]
	shl edi, 3
	add edi, IDT_ADDRESS
	mov eax, DWORD [ebp + 8]         ; Load the address of the interrupt handler into EAX
	mov WORD [edi], ax               ; Store the lower 16 bits of the handler address in the IDT entry for interrupt 49
	
	add edi, 2
	mov WORD [edi], 0x08             ; Store the code segment selector (needed for transitioning to code)
	
	add edi, 2
	mov WORD [edi], 0x8E00           ; Set up the interrupt gate descriptor (0x8E00 means present, privilege level 0, interrupt gate)
	
	add edi, 2
	shr eax, 16                      ; Shift the high 16 bits of the handler address into AX
	mov [edi], ax                    ; Store the upper 16 bits of the handler address in the IDT entry for interrupt 49
	");
}

int build_idt() {
	asm("
	;build idt
	mov ecx, IDT_ENTRIES * 2 / 4
	mov eax, 0
	mov edi, IDT_ADDRESS
	rep stosd
	
	;build idtr
	mov WORD [IDTR_ADDRESS], (IDT_ENTRIES*8)-1
	mov DWORD [IDTR_ADDRESS + 2], IDT_ADDRESS
	
	lidt [IDTR_ADDRESS]  ; Load the IDT register with the IDTR structure (points to our custom IDT)
	");
}

