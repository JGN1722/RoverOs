#include "pmm.h"

// false if free, true if allocated
uint8_t memory_bitmap[BITMAP_SIZE];

uint8_t bitmap_get(uint32_t block_index) {
	if (block_index >= MAX_BLOCK_NUMBER) return true;
	uint32_t byte_index = block_index >> 3;
	uint8_t bit_index = block_index & 3;
	
	return (memory_bitmap[byte_index] & (1 << bit_index)) != 0;
}

void bitmap_set(uint32_t block_index, uint8_t value) {
	if (block_index >= MAX_BLOCK_NUMBER) return;
	uint32_t byte_index = block_index >> 3;
	uint8_t bit = (1 << (block_index & 3));
	
	if (value) {
		memory_bitmap[byte_index] |= bit;
	} else {
		memory_bitmap[byte_index] &= ~bit;
	}
}

void *palloc() {
	memory_map_entry *entry = MEM_MAP_ENTRIES_START;
	uint32_t entry_count = *(uint32_t *)MEM_MAP_ADDRESS;
	
	while (entry_count > 0) {
		if (entry->type == 1 && !entry->base_hi) {
			uint32_t base_block = entry->base_low / PMM_BLOCK_SIZE;
			uint32_t len        = entry->len_low  / PMM_BLOCK_SIZE;
			
			for (uint32_t i = 0; i < len; i++) {
				uint32_t block = base_block + i;
				if (!bitmap_get(block)) {
					bitmap_set(block, true);
					return (void *)block * PMM_BLOCK_SIZE;
				}
			}
		}
			
		entry += sizeof(memory_map_entry);
		entry_count--;
	}

	return NULL; // No free blocks
}

void pfree(void *block) {
	uint32_t block_index = (uint32_t)(block) / PMM_BLOCK_SIZE;
	bitmap_set(block_index, false);
}

void enum_memory_map() {
	memory_map_entry *entry = MEM_MAP_ENTRIES_START;
	uint32_t entry_count = *(uint32_t *)MEM_MAP_ADDRESS;
	
	printf("Base Address\t\tLength\t\t\tType\t\tAcpi attribs\n");
	while (entry_count > 0) {
		printf("%d%d\t%d%d\t%d\t%d\n", entry->base_hi, entry->base_low, entry->len_hi, entry->len_low, entry->type, entry->acpi_attribs);
		entry += sizeof(memory_map_entry);
		entry_count--;
	}
}

uint32_t fill_bitmap() {
	memory_map_entry *entry = MEM_MAP_ENTRIES_START;
	uint32_t entry_count = *(uint32_t *)MEM_MAP_ADDRESS;
	uint32_t byte_count = 0;
	
	for (uint32_t i = 0; i < BITMAP_SIZE; i++) {
		memory_bitmap[i] = 0xff;
	}
	
	while (entry_count > 0) {
		if (entry->type == 1 && !entry->base_hi) {
			
			// Since we're a 32-bit OS, we do not care about the
			// high 64 bits of the address range anyways.
			// It's not like we can address it.
			uint32_t base_block = entry->base_low / PMM_BLOCK_SIZE;
			uint32_t len        = entry->len_low  / PMM_BLOCK_SIZE;
			
			for (i = 0; i < len; i++) {
				if (i >= 0x100) byte_count++;
				bitmap_set(base_block + i, false);
			}
		}
			
		entry += sizeof(memory_map_entry);
		entry_count--;
	}
	
	// Reserve the whole low memory for use by the kernel
	for (i = 0; i < 0x100; i++) {
		bitmap_set(i, true);
	}
	
	return byte_count * PMM_BLOCK_SIZE;
}

int setup_pmemory() {
	uint32_t detected_mem = fill_bitmap();
	printf("(detected 0x%d usable bytes)", detected_mem);
	
	if (detected_mem != 0) return 0;
	else return 1;
}
