include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\main_source\constants.inc"
include "C:\Users\comedelfini--thibaud\Desktop\RoverOs\kernel\io\io_driver.rl"

int main() {
	int i;
	
	clear_screen();
	set_cursor_pos(0,0);
	printf("Initializing system...\r\n");
	
	printf("Setting up IDT...\r\n");
	build_idt();
	
	i = 0;
	while i < #IDT_ENTRIES {
		install_interrupt_handler(i, @generic_interrupt_handler);
		i++;
	}
	
	asm("sti");
	
	do {}
}

int generic_interrupt_handler(int interrupt_number) {
	asm("pushad");
	
	if interrupt_number = 0 {
		printf("timer interrupt\r\n");
	} elseif interrupt_number = 1 {
		printf("keyboard interrupt\r\n");
	} elseif interrupt_number = 14 {
		printf("page fault\r\n");
	} else {
		printf("unhandled interrupt\r\n");
	}
	
	if (interrupt_number >= 32) {
		outb(0x20, 0x20);
		if (interrupt_number >= 40) {
			outb(0xA0, 0x20);
		}
	}
	
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
