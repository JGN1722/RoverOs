#ifndef _PMM_H
#define _PMM_H

#define PMM_BLOCK_SIZE 4096
#define MAX_MEMORY (4 * 1024 * 1024 * 1024) / 100
#define MAX_BLOCK_NUMBER (MAX_MEMORY / PMM_BLOCK_SIZE)
#define BITMAP_SIZE (MAX_BLOCK_NUMBER / 8)

// Temp until I find a suitable memory layout
#define MEM_MAP_ADDRESS (IDTR_ADDRESS + IDTR_SIZE)
#define MEM_MAP_ENTRIES_START (MEM_MAP_ADDRESS + 4)

struct memory_map_entry {
	uint32_t base_low, base_hi;
	uint32_t len_low, len_hi;
	
	uint32_t type;
	uint32_t acpi_attribs;
};
typedef struct memory_map_entry memory_map_entry;

#endif