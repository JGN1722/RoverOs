char inb(int port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in al, dx");
}

word inw(int port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in ax, dx");
}

int ind(int port) {
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in eax, dx");
}

void outb(int port, char data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, al");
}

void outw(int port, word data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, ax");
}

void outd(int port, int data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, eax");
}
