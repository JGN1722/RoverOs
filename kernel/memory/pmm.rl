\ Physical Memory Manager \

struct memory_map_entry {
	DWORD base_low, base_hi;
	DWORD len_low, len_hi;
	DWORD type;
	DWORD acpi_attribs;
}

int enum_memory_map() {
	int entry_count;
	struct memory_map_entry entry;
	
	entry = #MEM_MAP_ADDRESS;
	entry_count = DWORD *entry;
	entry += 4;
	
	printf("base\t\t\tlen\t\t\ttype\r\n");
	
	while (entry_count > 0) {
		printf(cstrud(entry.base_hi));
		printf(cstrud(entry.base_low));
		printf("\t");
		printf(cstrud(entry.len_hi));
		printf(cstrud(entry.len_low));
		printf("\t");
		printf(cstrud(entry.type));
		printf("\r\n");
		
		entry += 24;
		entry_count--;
	}
}

int fill_bitmap() {
	int entry_count;
	struct memory_map_entry entry;
	
	entry = #MEM_MAP_ADDRESS;
	entry_count = DWORD *entry;
	entry += 4;
	
	while (entry_count > 0) {
		if (entry.type = 1) {
			printf("usable memory region found");
		}
		
		entry += 24;
		entry_count--;
	}
}
