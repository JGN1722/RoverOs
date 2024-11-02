int build_idt() {
	asm("
	; Build IDT
	mov ecx, IDT_ENTRIES
	mov eax, 0
	mov edi, IDT_ADDRESS
	rep stosw
	
	; Build IDTR
	mov WORD [IDTR_ADDRESS], (IDT_ENTRIES*8)-1
	mov DWORD [IDTR_ADDRESS + 2], IDT_ADDRESS
	
	lidt [IDTR_ADDRESS]  ; Load the IDT register with the IDTR structure (points to our custom IDT)
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

int PIC_mask(int mask1, int mask2) {
	outb(#PIC1_DATA, mask1);
	outb(#PIC2_DATA, mask2);
}

int generic_interrupt_handler() {
	asm("pushad");
	
	printf("Unhandled interrupt received\r\n");
	
	asm("
	popad
	mov esp, ebp
	pop ebp
	iret
	");
}

int install_generic_interrupt_handler() {
	int i;
	
	i = 0;
	while i < #IDT_ENTRIES {
		install_interrupt_handler(i, @generic_interrupt_handler);
		i++;
	}
}