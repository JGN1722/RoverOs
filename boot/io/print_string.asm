print_string:
	pusha
	
	mov ah, 0x0e
	
	.print_next_char:
	;bx holds the address of the next char to print
	mov al, [bx]
	cmp al, 0
	je .end_print
	int 0x10
	inc bx
	jmp .print_next_char
	
	.end_print:
	
	popa
	ret