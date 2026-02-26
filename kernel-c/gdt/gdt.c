#include "gdt.h"

gdt_descriptor_t gdt[3];
gdtr_t gdtr;

void set_descriptor(int i, uint32_t base, uint32_t limit, uint16_t flags) {
	gdt[i].limit_low = limit & 0xffff;
	gdt[i].base_low = base & 0xffff;
	gdt[i].base_mid = (base >> 16) & 0xff;
	gdt[i].base_high = (base >> 24) & 0xff;
	gdt[i].flags1 = flags & 0xff;
	gdt[i].flags2 = ((flags >> 4) & 0xf0) | ((limit >> 16) & 0x0f);
}

void flush_gdt(gdtr_t *gdtr, uint16_t data_seg) {
	asm("mov	eax, DWORD [ebp + 8]");
	asm("lgdt	[eax]");
	
	asm("mov	ax, WORD [ebp + 12]");
	asm("mov	ds, ax");
	asm("mov	ss, ax");
	asm("mov	es, ax");
	asm("mov	fs, ax");
	asm("mov	gs, ax");
	asm("jmp	0x08:.end"); // I know hardcoding is bad but °w°
	asm(".end:");
}

int setup_gdt() {
	set_descriptor(NULL_SEG / sizeof(gdt_descriptor_t), 0, 0, 0);
	set_descriptor(CODE_SEG / sizeof(gdt_descriptor_t), 0, 0xfffff, 0b110010011010);
	set_descriptor(DATA_SEG / sizeof(gdt_descriptor_t), 0, 0xfffff, 0b110010010010);
	
	gdtr.size = sizeof(gdt) - 1;
	gdtr.base = &gdt;
	
	flush_gdt(&gdtr, DATA_SEG);
	return 0;
}