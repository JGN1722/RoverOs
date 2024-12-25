// Physical Memory Manager

struct memory_map_entry {
	int* base_low, base_hi;
	int len_low, len_hi;
	int type;
	int acpi_attribs;
}

int enum_memory_map() {
	int entry_count;
	int *entry_count_ptr;
	struct memory_map_entry *entry;
	
	entry_count_ptr = MEM_MAP_ADDRESS;
	entry_count = *entry_count_ptr;
	entry = MEM_MAP_ADDRESS + 4;
	
	printf("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZazertyuiopqsdfghjklmwxcvbn;.");
	printf("base\t\t\tlen\t\t\ttype\r\n");
	
	while (entry_count > 0) {
		printf(cstrud(entry->base_hi));
		printf(cstrud(entry->base_low));
		printf("\t");
		printf(cstrud(entry->len_hi));
		printf(cstrud(entry->len_low));
		printf("\t");
		printf(cstrud(entry->type));
		printf("\r\n");
		
		entry += 24;
		entry_count--;
	}
}

int fill_bitmap() {
	printf("\r\n\r\nMemory management constants:\r\n");
	printf("Block size: ");printf(cstrud(PMM_BLOCK_SIZE));printf("\r\n");
	printf("Maximum managed memory: ");printf(cstrud(MAX_MEMORY));printf("\r\n");
	printf("Block number: ");printf(cstrud(MAX_BLOCK_NUMBER));printf("\r\n");
	printf("Bitmap size: ");printf(cstrud(BITMAP_SIZE));printf("\r\n");
	printf("Bitmap sectors: ");printf(cstrud(BITMAP_SECTORS));printf("\r\n");
}