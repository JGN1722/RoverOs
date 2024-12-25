use32
org 32768
V_MAIN:
PUSH ebp
MOV ebp, esp
include '..\main_source\constants.asm'
CALL V_INIT_VGA
MOV eax, L0
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L1
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_ENUM_MEMORY_MAP
CALL V_FILL_BITMAP
MOV eax, L2
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_BUILD_IDT
CALL V_INSTALL_GENERIC_INTERRUPT_HANDLER
CALL V_INSTALL_EXCEPTION_INTERRUPTS
CALL V_INSTALL_IRQ_INTERRUPTS
MOV eax, 32
PUSHD eax
MOV eax, 40
PUSHD eax
CALL V_PIC_REMAP
ADD esp, 8
MOV eax, 253
PUSHD eax
MOV eax, 255
PUSHD eax
CALL V_PIC_MASK
ADD esp, 8
sti
MOV eax, L3
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L4:
MOV eax, 1
CMP eax, 0
JE L5
hlt
JMP L4
L5:
MOV eax, 0
JMP @f
@@:
MOV esp, ebp
POP ebp
RET
V_INB:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in al, dx
@@:
MOV esp, ebp
POP ebp
RET
V_INW:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in ax, dx
@@:
MOV esp, ebp
POP ebp
RET
V_IND:
PUSH ebp
MOV ebp, esp
MOV edx, DWORD [ebp + 8]
in eax, dx
@@:
MOV esp, ebp
POP ebp
RET
V_OUTB:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, al
@@:
MOV esp, ebp
POP ebp
RET
V_OUTW:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, ax
@@:
MOV esp, ebp
POP ebp
RET
V_OUTD:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, eax
@@:
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
	
@@:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_INIT_VGA:
PUSH ebp
MOV ebp, esp
CALL V_CLEAR_SCREEN
MOV eax, 15
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
MOV eax, 0
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_SET_TERMINAL_COLOR:
PUSH ebp
MOV ebp, esp
MOVZX eax, BYTE [ebp - (-8)]
MOV BYTE [V_TERMINAL_COLOR], al
@@:
MOV esp, ebp
POP ebp
RET
V_SET_BLINKING:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L7
MOVZX eax, BYTE[V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 127
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
JMP L6
L7:
MOVZX eax, BYTE[V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 127
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 128
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
L6:
@@:
MOV esp, ebp
POP ebp
RET
V_SET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-8)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
ADD eax, DWORD [esp]
ADD esp, 4
MOV WORD [ebp - (4)], ax
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 981
PUSHD eax
MOVZX eax, WORD [ebp - (4)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHR DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 981
PUSHD eax
MOVZX eax, WORD [ebp - (4)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_GET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 981
PUSHD eax
CALL V_INB
ADD esp, 4
MOV BYTE [ebp - (4)], al
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 981
PUSHD eax
CALL V_INB
ADD esp, 4
MOV BYTE [ebp - (8)], al
MOVZX eax, BYTE [ebp - (4)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOVZX eax, BYTE [ebp - (8)]
ADD eax, DWORD [esp]
ADD esp, 4
JMP @f
@@:
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
	
@@:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_PUTCHAR:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
SUB esp, 4
SUB esp, 4
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L9
MOVZX eax, BYTE[V_TERMINAL_COLOR]
MOV BYTE [ebp - (-8)], al
L9:
L8:
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, -1
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, -1
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 80
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 25
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
OR eax, DWORD [esp]
ADD esp, 4
CMP eax, 0
JE L11
CALL V_GET_CURSOR_POS
MOV DWORD [ebp - (8)], eax
MOV eax, DWORD [ebp - (8)]
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV eax, edx
MOV DWORD [ebp - (-16)], eax
MOV eax, DWORD [ebp - (8)]
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
SUB DWORD [esp], eax
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV DWORD [ebp - (-12)], eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 13
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L13
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L12
L13:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 10
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L14
MOV eax, DWORD [ebp - (-16)]
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (16)], eax
JMP L12
L14:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 9
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L15
; TAB =============================================================================================
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 8
PUSHD eax
MOV eax, 1
SUB DWORD [esp], eax
MOV eax, DWORD [esp]
ADD esp, 4
NEG eax
AND eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
;==================================================================================================
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 79
CMP DWORD [esp], eax
MOV eax, 0
SETA al
ADD esp, 4
CMP eax, 0
JE L17
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (16)]
INC eax
MOV DWORD [ebp - (16)], eax
L17:
L16:
JMP L12
L15:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 753664
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (4)], eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (4)]
MOV ebx, DWORD [esp]
MOV WORD [eax], bx
ADD esp, 4
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 79
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L19
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L18
L19:
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (16)], eax
L18:
L12:
MOV eax, DWORD [ebp - (16)]
PUSHD eax
MOV eax, 25
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
CMP eax, 0
JE L21
MOV eax, DWORD [ebp - (16)]
DEC eax
MOV DWORD [ebp - (16)], eax
CALL V_SCROLL
L21:
L20:
MOV eax, DWORD [ebp - (12)]
PUSH eax
CALL V_CSTRUD
ADD esp, 4
MOV edi, VIDEO_MEMORY + 20 * MAX_COLS * 2

		MOV esi, eax
		MOV edi, VIDEO_MEMORY + 20 * MAX_COLS * 2
		MOV ecx, 8
		.loop_here2:
		MOV al, BYTE [esi]
		MOV ah, 0x0f
		MOV WORD [edi], ax
		INC esi
		ADD edi, 2
		loop .loop_here2
		
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, DWORD [ebp - (16)]
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
JMP L10
L11:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 753664
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (4)], eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (4)]
MOV ebx, DWORD [esp]
MOV WORD [eax], bx
ADD esp, 4
L10:
@@:
MOV esp, ebp
POP ebp
RET
V_PRINTF:
PUSH ebp
MOV ebp, esp
L22:
MOV eax, DWORD [ebp - (-8)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETNE al
ADD esp, 4
CMP eax, 0
JE L23
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_PUTCHAR
ADD esp, 16
MOV eax, DWORD [ebp - (-8)]
INC eax
MOV DWORD [ebp - (-8)], eax
JMP L22
L23:
@@:
MOV esp, ebp
POP ebp
RET
V_SLEEP:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [esp], eax
L24:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 3145727
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L25
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L24
L25:
@@:
MOV esp, ebp
POP ebp
RET
V_ENUM_MEMORY_MAP:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
SUB esp, 4
MOV eax, 0
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
MOV DWORD [ebp - (8)], eax
MOV eax, DWORD [ebp - (8)]
MOV eax, DWORD [eax]
MOV DWORD [ebp - (4)], eax
MOV eax, 0
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
PUSHD eax
MOV eax, 4
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
MOV eax, L26
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L27
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L28:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETA al
ADD esp, 4
CMP eax, 0
JE L29
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 4
ADD eax, DWORD [esp]
ADD esp, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 0
ADD eax, DWORD [esp]
ADD esp, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L30
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 12
ADD eax, DWORD [esp]
ADD esp, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L31
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 16
ADD eax, DWORD [esp]
ADD esp, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L32
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, 24
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (4)]
DEC eax
MOV DWORD [ebp - (4)], eax
JMP L28
L29:
@@:
MOV esp, ebp
POP ebp
RET
V_FILL_BITMAP:
PUSH ebp
MOV ebp, esp
MOV eax, L33
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L34
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
MOV eax, L35
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L36
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 4294967295
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L37
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L38
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 4294967295
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
MOV eax, L39
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L40
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 4294967295
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
MOV eax, L41
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L42
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 4294967295
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
MOV eax, L43
PUSHD eax
CALL V_PRINTF
ADD esp, 4
@@:
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
	
@@:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_PIC_REMAP:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
MOV eax, 33
PUSHD eax
CALL V_INB
ADD esp, 4
MOV BYTE [ebp - (4)], al
MOV eax, 161
PUSHD eax
CALL V_INB
ADD esp, 4
MOV BYTE [ebp - (8)], al
MOV eax, 32
PUSHD eax
MOV eax, 16
PUSHD eax
MOV eax, 1
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 160
PUSHD eax
MOV eax, 16
PUSHD eax
MOV eax, 1
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, 2
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, 1
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, 1
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 33
PUSHD eax
MOVZX eax, BYTE [ebp - (4)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 161
PUSHD eax
MOVZX eax, BYTE [ebp - (8)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_PIC_MASK:
PUSH ebp
MOV ebp, esp
MOV eax, 33
PUSHD eax
MOVZX eax, BYTE [ebp - (-12)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 161
PUSHD eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
CALL V_OUTB
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L44
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_INSTALL_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [esp], eax
L45:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 256
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L46
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_GENERIC_INTERRUPT_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L45
L46:
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L47
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_NULL_DIV:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_OVERFLOW:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L49
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DOUBLE_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L50
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_SS_FAULT:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_GPF:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_PAGE_FAULT:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_FLOAT:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_INSTALL_EXCEPTION_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [esp], eax
L55:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 32
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L56
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_EXCEPT_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L55
L56:
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
@@:
MOV esp, ebp
POP ebp
RET
V_MASTER_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L57
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_SLAVE_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L58
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 160
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_INSTALL_IRQ_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 32
MOV DWORD [esp], eax
L59:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 32
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L60
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_MASTER_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L59
L60:
MOV eax, 40
MOV DWORD [ebp - (4)], eax
L61:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 40
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L62
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_SLAVE_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L61
L62:
MOV eax, 32
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, V_KEYBOARD_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_KEYBOARD_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L63
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L64
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 96
PUSHD eax
CALL V_INB
ADD esp, 4
PUSHD eax
CALL V_CSTRUB
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L65
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_OUTB
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_TERMINAL_COLOR rb 1
L0 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L1 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 13, 10, 0
L2 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L3 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L26 db 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 122, 101, 114, 116, 121, 117, 105, 111, 112, 113, 115, 100, 102, 103, 104, 106, 107, 108, 109, 119, 120, 99, 118, 98, 110, 59, 46, 0
L27 db 98, 97, 115, 101, 9, 9, 9, 108, 101, 110, 9, 9, 9, 116, 121, 112, 101, 13, 10, 0
L30 db 9, 0
L31 db 9, 0
L32 db 13, 10, 0
L33 db 13, 10, 13, 10, 77, 101, 109, 111, 114, 121, 32, 109, 97, 110, 97, 103, 101, 109, 101, 110, 116, 32, 99, 111, 110, 115, 116, 97, 110, 116, 115, 58, 13, 10, 0
L34 db 66, 108, 111, 99, 107, 32, 115, 105, 122, 101, 58, 32, 0
L35 db 13, 10, 0
L36 db 77, 97, 120, 105, 109, 117, 109, 32, 109, 97, 110, 97, 103, 101, 100, 32, 109, 101, 109, 111, 114, 121, 58, 32, 0
L37 db 13, 10, 0
L38 db 66, 108, 111, 99, 107, 32, 110, 117, 109, 98, 101, 114, 58, 32, 0
L39 db 13, 10, 0
L40 db 66, 105, 116, 109, 97, 112, 32, 115, 105, 122, 101, 58, 32, 0
L41 db 13, 10, 0
L42 db 66, 105, 116, 109, 97, 112, 32, 115, 101, 99, 116, 111, 114, 115, 58, 32, 0
L43 db 13, 10, 0
L44 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L47 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L48 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L49 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L50 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L51 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L52 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L53 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L54 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L57 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L58 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L63 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 32, 0
L64 db 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 0
L65 db 13, 10, 0
