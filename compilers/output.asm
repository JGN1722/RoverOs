use32
org 32768
JMP V_MAIN
V_INB:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in al, dx
RET_INB:
MOV esp, ebp
POP ebp
RET
V_INW:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in ax, dx
RET_INW:
MOV esp, ebp
POP ebp
RET
V_IND:
PUSH ebp
MOV ebp, esp
MOV edx, DWORD [ebp + 8]
in eax, dx
RET_IND:
MOV esp, ebp
POP ebp
RET
V_OUTB:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, al
RET_OUTB:
MOV esp, ebp
POP ebp
RET
V_OUTW:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, ax
RET_OUTW:
MOV esp, ebp
POP ebp
RET
V_OUTD:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, eax
RET_OUTD:
MOV esp, ebp
POP ebp
RET
V_CSTRUD:
PUSH ebp
MOV ebp, esp

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
	

	JMP .over_the_buffer
	.out_buff:
	times 8 db 0
	db 0
	.over_the_buffer:
	MOV eax, .out_buff
	
RET_CSTRUD:
MOV esp, ebp
POP ebp
RET
V_CSTRUB:
PUSH ebp
MOV ebp, esp

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
	

	JMP .over_the_buffer
	.out_buff:
	times 2 db 0
	db 0
	.over_the_buffer:
	MOV eax, .out_buff
	
RET_CSTRUB:
MOV esp, ebp
POP ebp
RET
V_INIT_VGA:
PUSH ebp
MOV ebp, esp
CALL V_CLEAR_SCREEN
MOV eax, 00fh
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
MOV eax, 0
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
RET_INIT_VGA:
MOV esp, ebp
POP ebp
RET
V_SET_TERMINAL_COLOR:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV DWORD [V_TERMINAL_COLOR], eax
RET_SET_TERMINAL_COLOR:
MOV esp, ebp
POP ebp
RET
V_SET_BLINKING:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L1
MOV eax, DWORD [V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 07fh
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
JMP L0
L1:
MOV eax, DWORD [V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 07fh
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 080h
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
JMP L0
L0:
RET_SET_BLINKING:
MOV esp, ebp
POP ebp
RET
V_SET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp + 8]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, 03D4h
PUSHD eax
MOV eax, 00Eh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 03D5h
PUSHD eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 8
MOV cl, al
SHR DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 03D4h
PUSHD eax
MOV eax, 00Fh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 03D5h
PUSHD eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
CALL V_OUTB
ADD esp, 8
RET_SET_CURSOR_POS:
MOV esp, ebp
POP ebp
RET
V_GET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, 03D4h
PUSHD eax
MOV eax, 00Eh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 03D5h
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, 03D4h
PUSHD eax
MOV eax, 00Fh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 03D5h
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - 8]
ADD eax, DWORD [esp]
ADD esp, 4
JMP RET_GET_CURSOR_POS
RET_GET_CURSOR_POS:
MOV esp, ebp
POP ebp
RET
V_CLEAR_SCREEN:
PUSH ebp
MOV ebp, esp

	pusha
	mov edi, VIDEO_MEMORY
	mov ax, WHITE_ON_BLACK * 256 + ' '
	mov ecx, MAX_ROWS * MAX_COLS
	rep stosw
	popa
	
RET_CLEAR_SCREEN:
MOV esp, ebp
POP ebp
RET
V_SCROLL:
PUSH ebp
MOV ebp, esp

	pusha
	mov edi, VIDEO_MEMORY
	mov esi, VIDEO_MEMORY + MAX_COLS * 2
	mov ecx, MAX_COLS * (MAX_ROWS - 1)
	rep movsw
	mov ax, WHITE_ON_BLACK * 256 + ' '
	mov ecx, MAX_COLS
	rep stosw
	popa
	
RET_SCROLL:
MOV esp, ebp
POP ebp
RET
V_PUTCHAR:
PUSH ebp
MOV ebp, esp
SUB esp, 16
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L3
MOV eax, DWORD [V_TERMINAL_COLOR]
MOV DWORD [ebp + 8], eax
JMP L2
L3:
L2:
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 0
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 0
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 25
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
OR eax, DWORD [esp]
ADD esp, 4
TEST eax, eax
JZ L5
CALL V_GET_CURSOR_POS
MOV DWORD [ebp - 4], eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV eax, edx
MOV DWORD [ebp + 16], eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, DWORD [ebp + 16]
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV DWORD [ebp + 12], eax
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
PUSHD eax
MOV eax, 13
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L7
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
JMP L6
L7:
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
PUSHD eax
MOV eax, 10
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L8
MOV eax, DWORD [ebp + 16]
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L6
L8:
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
PUSHD eax
MOV eax, 9
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L9
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 8
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
NOT eax
AND eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 79
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L11
MOV eax, 0
MOV DWORD [ebp - 12], eax
INC DWORD [ebp - 16]
JMP L10
L11:
L10:
JMP L6
L9:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp + 12]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 16]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 0B8000h
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 8]
MOV WORD [ebx], ax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 79
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L13
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
JMP L12
L13:
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L12
L12:
JMP L6
L6:
MOV eax, DWORD [ebp - 16]
PUSHD eax
MOV eax, 25
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L15
DEC DWORD [ebp - 16]
CALL V_SCROLL
JMP L14
L15:
L14:
MOV eax, DWORD [ebp - 12]
PUSHD eax
MOV eax, DWORD [ebp - 16]
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
JMP L4
L5:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp + 12]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 16]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 0B8000h
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 8]
MOV WORD [ebx], ax
JMP L4
L4:
RET_PUTCHAR:
MOV esp, ebp
POP ebp
RET
V_PRINTF:
PUSH ebp
MOV ebp, esp
L16:
MOV ebx, DWORD [ebp + 8]
MOV eax, 0
MOV al, BYTE [ebx]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETNE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L17
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 0
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
PUSHD eax
MOV eax, 0
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_PUTCHAR
ADD esp, 16
INC DWORD [ebp + 8]
JMP L16
L17:
RET_PRINTF:
MOV esp, ebp
POP ebp
RET
V_SLEEP:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [ebp - 4], eax
L18:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 04FFFFFh
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L19
INC DWORD [ebp - 4]
JMP L18
L19:
RET_SLEEP:
MOV esp, ebp
POP ebp
RET
V_ENUM_MEMORY_MAP:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, 00h
PUSHD eax
MOV eax, 256
PUSHD eax
MOV eax, 8
IMUL DWORD [esp]
ADD esp, 4
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 6
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV ebx, DWORD [ebp - 8]
MOV eax, 0
MOV eax, DWORD [ebx]
MOV DWORD [ebp - 4], eax
MOV eax, 4
ADD DWORD [ebp - 8], eax
MOV eax, L20
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L21:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L22
MOV eax, DWORD [ebp - 8]
ADD eax, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 0
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L23
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 12
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 8
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L24
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 16
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L25
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 24
ADD DWORD [ebp - 8], eax
DEC DWORD [ebp - 4]
JMP L21
L22:
RET_ENUM_MEMORY_MAP:
MOV esp, ebp
POP ebp
RET
V_GET_SECTOR_COUNT:
PUSH ebp
MOV ebp, esp

	mov eax, DWORD [ebp + 12]
	mov edx, DWORD [ebp + 16]
	
	shrd eax, edx, 10
	shr edx, 10
	
	cmp DWORD [ebp + 8], 0
	je .end
	mov eax, edx
	.end:
	
RET_GET_SECTOR_COUNT:
MOV esp, ebp
POP ebp
RET
V_ADD_QWORD:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L27
MOV eax, DWORD [ebp + 20]
PUSHD eax
MOV eax, DWORD [ebp + 12]
ADD eax, DWORD [esp]
ADD esp, 4
JMP RET_ADD_QWORD
JMP L26
L27:

		mov eax, DWORD [ebp + 16]        ; Load low dword of num1 into eax
		add eax, DWORD [ebp + 8]        ; Add low dword of num2
		
		; Add high dwords with carry
		mov eax, dword [ebp + 12]    ; Load high dword of num1 into eax
		adc eax, dword [ebp + 20]    ; Add high dword of num2 with carry from previous addition
		
JMP L26
L26:
RET_ADD_QWORD:
MOV esp, ebp
POP ebp
RET
V_COMPARE_QWORD:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 20]
PUSHD eax
MOV eax, DWORD [ebp + 12]
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L29
MOV eax, 1
JMP RET_COMPARE_QWORD
JMP L28
L29:
MOV eax, DWORD [ebp + 20]
PUSHD eax
MOV eax, DWORD [ebp + 12]
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
PUSHD eax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, DWORD [ebp + 8]
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
AND eax, DWORD [esp]
ADD esp, 4
TEST eax, eax
JZ L30
MOV eax, 1
JMP RET_COMPARE_QWORD
JMP L28
L30:
MOV eax, 0
JMP RET_COMPARE_QWORD
JMP L28
L28:
RET_COMPARE_QWORD:
MOV esp, ebp
POP ebp
RET
V_SORT_MEMORY_MAP:
PUSH ebp
MOV ebp, esp
RET_SORT_MEMORY_MAP:
MOV esp, ebp
POP ebp
RET
V_FILL_BITMAP:
PUSH ebp
MOV ebp, esp
SUB esp, 16
MOV eax, 00h
PUSHD eax
MOV eax, 256
PUSHD eax
MOV eax, 8
IMUL DWORD [esp]
ADD esp, 4
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 6
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV ebx, DWORD [ebp - 8]
MOV eax, 0
MOV eax, DWORD [ebx]
MOV DWORD [ebp - 4], eax
MOV eax, 4
ADD DWORD [ebp - 8], eax
L31:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L32
MOV eax, DWORD [ebp - 8]
ADD eax, 16
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, 1
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L34
MOV eax, DWORD [ebp - 8]
ADD eax, 12
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, DWORD [ebp - 8]
ADD eax, 8
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, 1
PUSHD eax
CALL V_GET_SECTOR_COUNT
ADD esp, 12
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp - 8]
ADD eax, 12
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, DWORD [ebp - 8]
ADD eax, 8
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_GET_SECTOR_COUNT
ADD esp, 12
MOV DWORD [ebp - 16], eax
MOV eax, L35
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 12]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 16]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L36
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L33
L34:
L33:
MOV eax, 24
ADD DWORD [ebp - 8], eax
DEC DWORD [ebp - 4]
JMP L31
L32:
MOV eax, L37
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L38
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 4096
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L39
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L40
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0FFFFFFFFh
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L41
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L42
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0FFFFFFFFh
PUSHD eax
MOV eax, 4096
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L43
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L44
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0FFFFFFFFh
PUSHD eax
MOV eax, 4096
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
MOV eax, 8
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L45
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L46
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0FFFFFFFFh
PUSHD eax
MOV eax, 4096
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
MOV eax, 8
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
MOV eax, 4096
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L47
PUSHD eax
CALL V_PRINTF
ADD esp, 4
RET_FILL_BITMAP:
MOV esp, ebp
POP ebp
RET
V_BUILD_IDT:
PUSH ebp
MOV ebp, esp

	; Build IDT
	mov ecx, IDT_ENTRIES
	mov eax, 0
	mov edi, IDT_ADDRESS
	rep stosw
	
	; Build IDTR
	mov WORD [IDTR_ADDRESS], (IDT_ENTRIES*8)-1
	mov DWORD [IDTR_ADDRESS + 2], IDT_ADDRESS
	
	lidt [IDTR_ADDRESS]  ; Load the IDT register with the IDTR structure (points to our custom IDT)
	
RET_BUILD_IDT:
MOV esp, ebp
POP ebp
RET
V_INSTALL_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp

	mov edi, DWORD [ebp + 12]
	shl edi, 3
	add edi, IDT_ADDRESS
	mov eax, DWORD [ebp + 8]         ; Load the address of the interrupt handler into EAX
	mov WORD [edi], ax               ; Store the lower 16 bits of the handler address in the IDT entry for interrupt 49
	
	add edi, 2
	mov WORD [edi], 0x08             ; Store the code segment selector (needed for transitioning to code)
	
	add edi, 2
	mov WORD [edi], 0x8E00           ; Set up the interrupt gate descriptor (0x8E00 means present, privilege level 0, interrupt gate)
	
	add edi, 2
	shr eax, 16                      ; Shift the high 16 bits of the handler address into AX
	mov [edi], ax                    ; Store the upper 16 bits of the handler address in the IDT entry for interrupt 49
	
RET_INSTALL_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_PIC_REMAP:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, 021h
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, 0A1h
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, 020h
PUSHD eax
MOV eax, 010h
PUSHD eax
MOV eax, 001h
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A0h
PUSHD eax
MOV eax, 010h
PUSHD eax
MOV eax, 001h
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 021h
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A1h
PUSHD eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 021h
PUSHD eax
MOV eax, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A1h
PUSHD eax
MOV eax, 2
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 021h
PUSHD eax
MOV eax, 001h
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A1h
PUSHD eax
MOV eax, 001h
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 021h
PUSHD eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A1h
PUSHD eax
MOV eax, DWORD [ebp - 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
RET_PIC_REMAP:
MOV esp, ebp
POP ebp
RET
V_PIC_MASK:
PUSH ebp
MOV ebp, esp
MOV eax, 021h
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 0A1h
PUSHD eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
RET_PIC_MASK:
MOV esp, ebp
POP ebp
RET
V_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L48
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_GENERIC_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_INSTALL_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [ebp - 4], eax
L49:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 256
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L50
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_GENERIC_INTERRUPT_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L49
L50:
RET_INSTALL_GENERIC_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L51
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_NULL_DIV:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L52
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_NULL_DIV:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_OVERFLOW:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L53
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_OVERFLOW:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DOUBLE_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L54
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_DOUBLE_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_SS_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L55
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_SS_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_GPF:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L56
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_GPF:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_PAGE_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L57
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_PAGE_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_FLOAT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L58
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_FLOAT:
MOV esp, ebp
POP ebp
RET
V_INSTALL_EXCEPTION_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [ebp - 4], eax
L59:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 32
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L60
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_EXCEPT_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L59
L60:
MOV eax, 0
PUSHD eax
MOV eax, V_EXCEPT_NULL_DIV
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 4
PUSHD eax
MOV eax, V_EXCEPT_OVERFLOW
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 8
PUSHD eax
MOV eax, V_EXCEPT_DOUBLE_FAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 12
PUSHD eax
MOV eax, V_EXCEPT_SS_FAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 13
PUSHD eax
MOV eax, V_EXCEPT_GPF
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 14
PUSHD eax
MOV eax, V_EXCEPT_PAGE_FAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, 16
PUSHD eax
MOV eax, V_EXCEPT_FLOAT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
RET_INSTALL_EXCEPTION_INTERRUPTS:
MOV esp, ebp
POP ebp
RET
V_MASTER_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L61
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 020h
PUSHD eax
MOV eax, 020h
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_MASTER_IRQ_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_SLAVE_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L62
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0A0h
PUSHD eax
MOV eax, 020h
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 020h
PUSHD eax
MOV eax, 020h
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_SLAVE_IRQ_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_INSTALL_IRQ_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 020h
MOV DWORD [ebp - 4], eax
L63:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 020h
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L64
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_MASTER_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L63
L64:
MOV eax, 028h
MOV DWORD [ebp - 4], eax
L65:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 028h
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L66
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_SLAVE_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L65
L66:
MOV eax, 020h
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, V_KEYBOARD_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
RET_INSTALL_IRQ_INTERRUPTS:
MOV esp, ebp
POP ebp
RET
V_MAIN:
PUSH ebp
MOV ebp, esp
include '..\boot\constants.inc'
CALL V_INIT_VGA
MOV eax, L67
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L68
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_SORT_MEMORY_MAP
CALL V_ENUM_MEMORY_MAP
CALL V_FILL_BITMAP
MOV eax, L69
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_BUILD_IDT
CALL V_INSTALL_GENERIC_INTERRUPT_HANDLER
CALL V_INSTALL_EXCEPTION_INTERRUPTS
CALL V_INSTALL_IRQ_INTERRUPTS
MOV eax, 020h
PUSHD eax
MOV eax, 028h
PUSHD eax
CALL V_PIC_REMAP
ADD esp, 8
MOV eax, 0fdh
PUSHD eax
MOV eax, 0ffh
PUSHD eax
CALL V_PIC_MASK
ADD esp, 8
sti
MOV eax, L70
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L71:
hlt
JMP L71
L72:
RET_MAIN:
MOV esp, ebp
POP ebp
RET
V_KEYBOARD_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L73
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L74
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 060h
PUSHD eax
CALL V_INB
ADD esp, 4
PUSHD eax
CALL V_CSTRUB
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L75
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 020h
PUSHD eax
MOV eax, 020h
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_KEYBOARD_HANDLER:
MOV esp, ebp
POP ebp
RET
V_TERMINAL_COLOR dd 0
L20 db 98, 97, 115, 101, 9, 9, 9, 108, 101, 110, 9, 9, 9, 116, 121, 112, 101, 13, 10, 0
L23 db 9, 0
L24 db 9, 0
L25 db 13, 10, 0
L35 db 115, 101, 99, 116, 111, 114, 32, 99, 111, 117, 110, 116, 58, 32, 0
L36 db 13, 10, 0
L37 db 13, 10, 13, 10, 77, 101, 109, 111, 114, 121, 32, 109, 97, 110, 97, 103, 101, 109, 101, 110, 116, 32, 99, 111, 110, 115, 116, 97, 110, 116, 115, 58, 13, 10, 0
L38 db 66, 108, 111, 99, 107, 32, 115, 105, 122, 101, 58, 32, 0
L39 db 13, 10, 0
L40 db 77, 97, 120, 105, 109, 117, 109, 32, 109, 97, 110, 97, 103, 101, 100, 32, 109, 101, 109, 111, 114, 121, 58, 32, 0
L41 db 13, 10, 0
L42 db 66, 108, 111, 99, 107, 32, 110, 117, 109, 98, 101, 114, 58, 32, 0
L43 db 13, 10, 0
L44 db 66, 105, 116, 109, 97, 112, 32, 115, 105, 122, 101, 58, 32, 0
L45 db 13, 10, 0
L46 db 66, 105, 116, 109, 97, 112, 32, 115, 101, 99, 116, 111, 114, 115, 58, 32, 0
L47 db 13, 10, 0
L48 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L51 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L52 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L53 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L54 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L55 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L56 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L57 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L58 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L61 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L62 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L67 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L68 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 13, 10, 0
L69 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L70 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L73 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 32, 0
L74 db 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 0
L75 db 13, 10, 0
