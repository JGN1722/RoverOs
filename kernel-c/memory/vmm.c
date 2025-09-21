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

/**
* Returns the address of the page table at index i in the virtual
* address space
*/
uint32_t *get_page_table_vaddr(uint32_t i) {
	return (uint32_t *)(0xffc00000 + i * 0x1000);
}

/**
* Returns the physical address of the page table at index i 
*/
uint32_t *get_page_table_paddr(uint32_t i) {
	return page_directory[i] & PG_ADDR_MASK;
}

/**
* Returns false if the virtual address is already
* mapped, true otherwise
*/
int map_virtual_to_physical(void *vaddr, void *paddr) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	// Protect the recursive mapping
	if (page_table_index == 1023) return false;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) {
		page_directory[page_table_index] = palloc() | PG_PRESENT | PG_WRITE;
		
		uint32_t *page_table = get_page_table_vaddr(page_table_index);
		for (uint32_t i = 0; i < 1024; i++) {
			page_table[i] = 0x00000000 | PG_WRITE;
		}
	}
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	if (page_table[entry_index] & PG_PRESENT) {
		return false; // The page is already mapped
	}
	
	page_table[entry_index] = (paddr & PG_ADDR_MASK) | PG_PRESENT | PG_WRITE;
	invalidate_TLB();
	return true;
}

void unmap_vaddr(void *vaddr) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) return;
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	page_table[entry_index] = 0x00000000 | PG_WRITE;
	
	// Free the page table if it's now empty
	for (int i = 0; i < 1024; i++) {
		if (page_table[i] & PG_PRESENT) return;
	}
	pfree(get_page_table_paddr(page_table_index));
	invalidate_TLB();
}

/**
* Sets the specified flags from a page table entry. For clearing flags, see the next function
*/
void set_page_flags(void *vaddr, uint32_t flags) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) return;
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	page_table[entry_index] = page_table[entry_index] | (flags & 0xfff);
}

/**
* Clears the specified flags from a page table entry.
*/
void clear_page_flags(void *vaddr, uint32_t flags) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) return;
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	page_table[entry_index] = page_table[entry_index] & ~(flags & 0xfff);
}

uint32_t get_page_flags(void *vaddr) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) return;
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	return page_table[entry_index] & 0xfff;
}

/**
* Returns the physical address corresponding to the virtual address
*/
void *translate_vaddr(void *vaddr) {
	uint32_t page_table_index = (uint32_t)(vaddr >> 22) & 0x3FF;
	uint32_t entry_index = (uint32_t)(vaddr >> 12) & 0x3FF;
	
	if (!(page_directory[page_table_index] & PG_PRESENT)) return;
	
	uint32_t *page_table = get_page_table_vaddr(page_table_index);
	
	return page_table[entry_index] & PG_ADDR_MASK + (vaddr & 0xfff);
}

void setup_vmemory() {
	// Zero the page directory
	for (uint32_t i = 0; i < 1024; i++) {
		page_directory[i] = 0x00000000 | PG_WRITE;
	}
	
	// Set up the recursive mapping
	page_directory[1023] = (page_directory & PG_ADDR_MASK) | PG_PRESENT | PG_WRITE;
	
	// identity map the first 4 Mib
	uint32_t *page_table = (uint32_t *)(palloc());
	for (i = 0; i < 1024; i++) {
		page_table[i] = (i * 0x1000) | PG_PRESENT | PG_WRITE;
	}
	page_directory[0] = ((uint32_t)page_table) | PG_PRESENT | PG_WRITE;
	
	enable_paging(page_directory);
}
