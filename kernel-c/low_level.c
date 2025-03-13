uint8_t inb(uint32_t port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in al, dx");
}

uint16_t inw(uint32_t port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in ax, dx");
}

uint32_t ind(uint32_t port) {
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in eax, dx");
}

void outb(uint32_t port, uint8_t data) {
	asm("MOV eax, DWORD [ebp + 12]");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("out dx, al");
}

void outw(uint32_t port, uint16_t data) {
	asm("MOV eax, DWORD [ebp + 12]");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("out dx, ax");
}

void outd(uint32_t port, uint32_t data) {
	asm("MOV eax, DWORD [ebp + 12]");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("out dx, eax");
}
