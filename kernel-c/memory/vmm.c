#include "vmm.h"

[[align(4096)]] uint32_t page_directory[1024];

void load_page_dir(uint32_t *page_directory) {
	asm("mov eax, DWORD [ebp + 8]");
	asm("mov cr3, eax");
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
		page_directory[page_table_index] = palloc() | PG_PRESENT | PG_WRITE; // TODO: check for out of mem
		
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
	
	// Map first 4 Mib to the the third Gib, that's where the kernel is
	uint32_t *page_table = (uint32_t *)(palloc()); // TODO: check for out of mem
	
	// Here's a bit of a hack, to solve the problem of the page table's physical
	// address not being mapped. What I'm gonna do is get the bootloader's
	// page directory, and set the page table address as a page table there.
	// Then, I can access it using the recursive mapping trick.
	uint32_t *bootloader_page_dir;
	asm("mov eax, cr3");
	asm("mov DWORD [esp], eax");
	bootloader_page_dir += 0xc0000000; // Convert to virtual address
	
	bootloader_page_dir[1] = page_table | PG_PRESENT | PG_WRITE;
	
	uint32_t *page_table_vaddr = 0xffc01000;
	for (i = 0; i < 1024; i++) {
		page_table_vaddr[i] = (i * 0x1000) | PG_PRESENT | PG_WRITE;
	}
	page_directory[0x300] = ((uint32_t)page_table) | PG_PRESENT | PG_WRITE;
	
	load_page_dir(page_directory - 0xc0000000);
}
