print_string:
	mov	ah, 0x0e
	
	.print_next_char:
	lodsb		;si holds the address of the next char to print
	cmp	al, 0
	je	$
	int	0x10
	jmp	.print_next_char