#include "vmm.h"

[[align(4096)]] uint32_t page_directory[1024];

void enable_paging(uint32_t *page_directory) {
	// Load the page directory
	asm("mov eax, DWORD [ebp + 8]");
	asm("mov cr3, eax");
	
	// Actually enable paging
	asm("mov eax, cr0");
	asm("or eax, 0x80000000");
	asm("mov cr0, eax");
}

void invalidate_TLB() {
	asm("mov eax, cr3");
	asm("mov cr3, eax");
}

void setup_vmemory() {
	// Zero the page directory
	for (uint32_t i = 0; i < 1024; i++) {
		page_directory[i] = 0x00000000 | PG_WRITE;
	}
	
	// Allocate a new page table
	uint32_t *page_table = (uint32_t *)(palloc());
	
	// Map to the first Mib
	for (i = 0; i < 1024; i++) {
		page_table[i] = (i * 0x1000) | PG_PRESENT | PG_WRITE;
	}
	
	page_directory[0] = ((uint32_t)page_table) | PG_PRESENT | PG_WRITE;
	
	enable_paging(page_directory);
	
	*(uint8_t *)(0x400000 - 1);
}