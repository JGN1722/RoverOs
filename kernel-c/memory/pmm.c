#include "pmm.h"

uint8_t memory_bitmap[BITMAP_SIZE];

uint8_t bitmap_get(uint32_t block_index) {
	uint32_t byte_index = block_index >> 3;
	uint8_t bit_index = block_index & 3;
	
	return (memory_bitmap[byte_index] & (1 << bit_index)) != 0;
}

void bitmap_set(uint32_t block_index, uint8_t value) {
	uint32_t byte_index = block_index >> 3;
	uint8_t bit = (1 << (block_index & 3));
	
	if (value) {
		memory_bitmap[byte_index] |= bit;
	} else {
		memory_bitmap[byte_index] &= ~bit;
	}
}

void *palloc() { // can be sped up with uint32_t comparisons
	for (uint32_t i = 0; i < MAX_BLOCK_NUMBER; i++) {
		if (!bitmap_get(i)) {
			bitmap_set(i, true);
			return (void *)(i * PMM_BLOCK_SIZE);
		}
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
	
	printf("Base Address\t\tLength\t\t\tType\t\tAcpi attribs\r\n");
	while (entry_count > 0) {
		printf("%d%d\t%d%d\t%d\t%d\r\n", entry->base_hi, entry->base_low, entry->len_hi, entry->len_low, entry->type, entry->acpi_attribs);
		entry += sizeof(memory_map_entry);
		entry_count--;
	}
}

void fill_bitmap() {
	memory_map_entry *entry = MEM_MAP_ENTRIES_START;
	uint32_t entry_count = *(uint32_t *)MEM_MAP_ADDRESS;
	
	for (uint32_t i = 0; i < BITMAP_SIZE; i++) {
		memory_bitmap[i] = 0xff;
	}
	
	while (entry_count > 0) {
		// ...
		
		entry += sizeof(memory_map_entry);
		entry_count--;
	}
}

void setup_memory() {
	// fill_bitmap();
}
