#define PMM_BLOCK_SIZE 4096			// Memory block size in bytes
#define MAX_MEMORY (4 * 1024 * 1024 * 1024)	// Maximum managed memory (e.g., 4GB)
#define MAX_BLOCK_NUMBER (MAX_MEMORY / PMM_BLOCK_SIZE)
#define BITMAP_SIZE (MAX_BLOCK_NUMBER / 8)	// Size of the bitmap (in bytes)

uint8_t memory_bitmap[BITMAP_SIZE];		// Bitmap to manage memory blocks

struct memory_map_entry {
	uint32_t base_low, base_hi;		// Base address of the memory region

	uint32_t len_low, len_hi;		// Length of the memory region
	uint32_t type;				// Type (1 = usable, others = reserved)
	uint32_t acpi_attribs;
};

void bitmap_set(uint32_t block_index, bool value) {
	uint32_t byte_index = block_index / 8;
	uint8_t bit_index = block_index % 8;

	if (value) {
		memory_bitmap[byte_index] |= (1 << bit_index);
	} else {
		memory_bitmap[byte_index] &= ~(1 << bit_index);
	}
}

bool bitmap_get(uint32_t block_index) {
	uint32_t byte_index = block_index / 8;
	uint8_t bit_index = block_index % 8;

	return (memory_bitmap[byte_index] & (1 << bit_index)) != 0;
}

void enum_memory_map() {
	struct memory_map_entry* entry = MEM_MAP_ADDRESS;
	uint32_t entry_count = *(uint32_t*)MEM_MAP_ADDRESS; // Mock: replace as needed

	printf("Base Address\t\tLength\t\t\tType\n");
	while (entry_count > 0) {
		uint64_t base = ((uint64_t)entry->base_hi << 32) | entry->base_low;
		uint64_t length = ((uint64_t)entry->len_hi << 32) | entry->len_low;

		printf("0x%016llx\t0x%016llx\t%d\n", base, length, entry->type);

		entry++;
		entry_count--;
	}
}

void fill_bitmap() {
	struct memory_map_entry* entry = MEM_MAP_ADDRESS;
	uint32_t entry_count = *(uint32_t*)MEM_MAP_ADDRESS; // Mock: replace as needed

	// Mark all blocks as used initially
	for (uint32_t i = 0; i < MAX_BLOCK_NUMBER; i++) {
		bitmap_set(i, true);
	}

	// Iterate through memory map and mark usable blocks
	while (entry_count > 0) {
		uint64_t base = ((uint64_t)entry->base_hi << 32) | entry->base_low;
		uint64_t length = ((uint64_t)entry->len_hi << 32) | entry->len_low;

		if (entry->type == 1) { // Usable memory
			uint32_t start_block = base / PMM_BLOCK_SIZE;
			uint32_t block_count = length / PMM_BLOCK_SIZE;

			for (uint32_t i = 0; i < block_count; i++) {
				bitmap_set(start_block + i, false); // Mark as free
			}
		}

		entry++;
		entry_count--;
	}

	printf("\nBitmap initialization complete.\n");
}

// Allocate a memory block
void* allocate_block() {
	for (uint32_t i = 0; i < MAX_BLOCK_NUMBER; i++) {
		if (!bitmap_get(i)) { // If block is free
			bitmap_set(i, true); // Mark as used
			return (void*)(i * PMM_BLOCK_SIZE); // Return block address
		}
	}

	return NULL; // No free blocks
}

// Free a memory block
void free_block(void* block) {
	uint32_t block_index = (uint32_t)block / PMM_BLOCK_SIZE;
	bitmap_set(block_index, false); // Mark block as free
}
