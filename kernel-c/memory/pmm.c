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
	entry = MEM_MAP_ADDRESS + 4;
	entry_count = *entry_count_ptr;
	
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

// Pas correct, il faut >> 12 au lieu de >> 10
int get_sector_count(int high, int low, int high_or_low) {
	asm("
	mov eax, DWORD [ebp + 12]
	mov edx, DWORD [ebp + 16]
	
	shrd eax, edx, 10
	shr edx, 10
	
	cmp DWORD [ebp + 8], 0
	je .end
	mov eax, edx
	.end:
	");
}

// Renvoie la partie haute de l'addition des 2 qwords si hi_or_low = 1, la partie basse sinon
int add_qword(int hi1, int low1, int hi2, int low2, int hi_or_low) {
	if (hi_or_low == 0) {
		return low1 + low2;
	} else {
		asm("
		mov eax, DWORD [ebp + 16]        ; Load low dword of num1 into eax
		add eax, DWORD [ebp + 8]        ; Add low dword of num2
		
		; Add high dwords with carry
		mov eax, dword [ebp + 12]    ; Load high dword of num1 into eax
		adc eax, dword [ebp + 20]    ; Add high dword of num2 with carry from previous addition
		");
	}
}

// Renvoie 1 si qword1 > qword2, 0 sinon
int compare_qword(int hi1, int low1, int hi2, int low2) {
	if (hi1 > hi2) {
		return 1;
	} elseif (hi1 == hi2 && low1 > low2) {
		return 1;
	} else {
		return 0;
	}
}

// Trie par ordre croissant des adresses de base les entrees de la carte de la memoire
int sort_memory_map() {
	
}		

int fill_bitmap() {
	printf("\r\n\r\nMemory management constants:\r\n");
	printf("Block size: ");printf(cstrud(PMM_BLOCK_SIZE));printf("\r\n");
	printf("Maximum managed memory: ");printf(cstrud(MAX_MEMORY));printf("\r\n");
	printf("Block number: ");printf(cstrud(MAX_BLOCK_NUMBER));printf("\r\n");
	printf("Bitmap size: ");printf(cstrud(BITMAP_SIZE));printf("\r\n");
	printf("Bitmap sectors: ");printf(cstrud(BITMAP_SECTORS));printf("\r\n");
}