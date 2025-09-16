;REQUIRES PRINT_STRING

buff db '0x',0,0,0,0,0

print_hex:
	pusha
	
	mov	di, buff + 5
	
	.fill_next_char:
	cmp	di, buff + 1
	je	.end
	
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
	
	mov	BYTE [di], al
	dec	di
	
	jmp	.fill_next_char
	
	.end:
	mov	si, buff
	call	print_string
	
	popa
	ret
