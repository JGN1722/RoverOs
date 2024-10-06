;REQUIRES PRINT_STRING

OUT_HEX:
db '0','x'
.string_part:
db 0,0,0,0
.null_terminator:
db 0

print_hex:
	pusha

	mov cx, 0
	mov dx, OUT_HEX.string_part
	
	.fill_next_char:
	cmp cl, 4
	je .end_filling
	
	;get the nibble to print in al-low
	mov ax, bx ; move in ax the value of the whole number
	shr ax, cl ; what we want is to get the nibble at index cl
	shr ax, cl ; thus, we need to shift by 4 bits, cl times
	shr ax, cl ; or cl bits, 4 times
	shr ax, cl ; and then we get the desired nibble in the low nibble
	and ax, 0xf; we can then and it with 0xF to get it alone
	
	;convert to character
	cmp al, 0xa
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,0xa
	add al,'A'
	
	.poke:
	;the nibble is now in al-low
	;move it to the desired part of the string
	;the string begins at dx
	;we want to poke the nibble in dx + cl
	mov di, dx
	add di, 3
	sub di, cx
	mov BYTE [di], al
	
	inc cx
	jmp .fill_next_char
	
	.end_filling:
	
	mov bx, OUT_HEX
	call print_string
	
	popa
	ret