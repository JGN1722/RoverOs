#ifndef _PMM_H
#define _PMM_H

#define MEM_MAP_ADDRESS 0xc0002000
#define MEM_MAP_ENTRIES_START (MEM_MAP_ADDRESS + 4)

#define PMM_BLOCK_SIZE 4096
#define MAX_MEMORY (4 * 1024 * 1024 * 1024)
#define MAX_BLOCK_NUMBER (MAX_MEMORY / PMM_BLOCK_SIZE)
#define BITMAP_SIZE (MAX_BLOCK_NUMBER / 8)

struct memory_map_entry {
	uint32_t base_low, base_hi;
	uint32_t len_low, len_hi;
	
	uint32_t type;
	uint32_t acpi_attribs;
};
typedef struct memory_map_entry memory_map_entry;

uint8_t bitmap_get(uint32_t block_index);
void bitmap_set(uint32_t block_index, uint8_t value);
void *palloc();
void pfree(void *block);
void enum_memory_map();
uint32_t fill_bitmap();
int setup_pmemory(); 

#endif