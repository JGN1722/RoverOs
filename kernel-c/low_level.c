int inb(int port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in al, dx");
}

int inw(int port) {
	asm("XOR eax, eax");
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in ax, dx");
}

int ind(int port) {
	asm("MOV edx, DWORD [ebp + 8]");
	asm("in eax, dx");
}

int outb(int port, int data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, al");
}

int outw(int port, int data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, ax");
}

int outd(int port, int data) {
	asm("MOV eax, DWORD [ebp + 8]");
	asm("MOV edx, DWORD [ebp + 12]");
	asm("out dx, eax");
}
