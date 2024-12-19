char* cstrud(int num) {
	asm("
	mov ecx, 0
	
	.fill_next_char:
	cmp ecx, 8	; I want to print 8 nibbles / 4 bytes / 1 DWORD
	je .end_filling
	push ecx	; ecx might be modified, so save it
	
			;get the nibble to print in al-low
	mov eax, DWORD [ebp + 8]
	shl ecx, 2
	shr eax, cl
	and eax, 0xf
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 0xa	;convert to character
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
	mov edi, .out_buff
	add edi, 7
	sub edi, ecx
	mov BYTE [edi], al
	
	inc ecx
	jmp .fill_next_char
	
	.end_filling:
	");
	
	asm("
	JMP .over_the_buffer
	.out_buff:
	times 8 db 0
	db 0
	.over_the_buffer:
	MOV eax, .out_buff
	");
}

char* cstrub(int num) {
	asm("
	mov ecx, 0
	
	.fill_next_char:
	cmp ecx, 2	; I want to print 8 nibbles / 4 bytes / 1 DWORD
	je .end_filling
	push ecx	; ecx might be modified, so save it
	
			;get the nibble to print in al-low
	mov eax, DWORD [ebp + 8]
	shl ecx, 2
	shr eax, cl
	and eax, 0xf
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 0xa	;convert to character
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
	mov edi, .out_buff
	add edi, 1
	sub edi, ecx
	mov BYTE [edi], al
	
	inc ecx
	jmp .fill_next_char
	
	.end_filling:
	");
	
	asm("
	JMP .over_the_buffer
	.out_buff:
	times 2 db 0
	db 0
	.over_the_buffer:
	MOV eax, .out_buff
	");
}
