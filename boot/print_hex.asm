;REQUIRES PRINT_STRING

buff db '0x',0,0,0,0,0

print_hex:
	mov	si, buff + 4
	
	.fill_next_char:
	cmp	si, buff
	je	print_string
	
	;get the nibble to print in al-low
	mov	al, bl
	and	al, 0xf
	shr	bx, 4
	
	;convert to character
	cmp	al, 0xa
	jb	.not_letter
	add	al, 7 ; -10 + 'A' = '7' = '0' + 7
	.not_letter:
	add	al, '0'
	
	mov	BYTE [si + 1], al
	dec	si
	
	jmp	.fill_next_char
