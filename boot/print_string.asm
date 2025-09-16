print_string:
	mov ah, 0x0e
	
	.print_next_char:
	;si holds the address of the next char to print
	lodsb
	cmp al, 0
	je .end_print
	int 0x10
	jmp .print_next_char
	
	.end_print:
	
	;we only ever call print_string for error messages
	jmp $