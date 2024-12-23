use32
org 32768
V_MAIN:
PUSH ebp
MOV ebp, esp
include '..\main_source\constants.inc'
CALL V_INIT_VGA
MOV eax, L0
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L1
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
MOV eax, 31
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
MOV eax, 1
PUSHD eax
CALL V_SET_BLINKING
ADD esp, 4
MOV eax, L2
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0
PUSHD eax
CALL V_SET_BLINKING
ADD esp, 4
MOV eax, L3
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L5:
MOV eax, 1
CMP eax, 0
JE L6
hlt
JMP L5
L6:
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
JE L8
MOVZX eax, BYTE[V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 127
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
JMP L7
L8:
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
L7:
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
JE L10
MOVZX eax, BYTE[V_TERMINAL_COLOR]
MOV BYTE [ebp - (-8)], al
L10:
L9:
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
JE L12
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
JE L14
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L13
L14:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 10
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L15
MOV eax, DWORD [ebp - (-16)]
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (16)], eax
JMP L13
L15:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 9
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L16
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
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
JE L18
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (16)]
INC eax
MOV DWORD [ebp - (16)], eax
L18:
L17:
JMP L13
L16:
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
JE L20
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L19
L20:
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - (16)], eax
L19:
L13:
MOV eax, DWORD [ebp - (16)]
PUSHD eax
MOV eax, 25
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
CMP eax, 0
JE L22
MOV eax, DWORD [ebp - (16)]
DEC eax
MOV DWORD [ebp - (16)], eax
CALL V_SCROLL
L22:
L21:
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, DWORD [ebp - (16)]
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
JMP L11
L12:
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
L11:
@@:
MOV esp, ebp
POP ebp
RET
V_PRINTF:
PUSH ebp
MOV ebp, esp
L23:
MOV eax, DWORD [ebp - (-8)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETNE al
ADD esp, 4
CMP eax, 0
JE L24
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
JMP L23
L24:
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
L25:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 3145727
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L26
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L25
L26:
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
MOV eax, L27
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
L28:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 256
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L29
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_GENERIC_INTERRUPT_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L28
L29:
@@:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L30
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
MOV eax, L31
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
MOV eax, L32
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
MOV eax, L33
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
MOV eax, L34
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
MOV eax, L35
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
MOV eax, L36
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
MOV eax, L37
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
L38:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 32
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L39
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_EXCEPT_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L38
L39:
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
MOV eax, L40
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
MOV eax, L41
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
L42:
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
JE L43
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_MASTER_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L42
L43:
MOV eax, 40
MOV DWORD [ebp - (4)], eax
L44:
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
JE L45
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_SLAVE_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L44
L45:
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
MOV eax, L46
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L47
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
MOV eax, L48
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
L1 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L2 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 32, 98, 108, 105, 110, 107, 13, 10, 0
L3 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 110, 39, 116, 13, 10, 0
L4 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L27 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L30 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L31 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L32 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L33 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L34 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L35 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L36 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L37 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L40 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L41 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L46 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 0
L47 db 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 0
L48 db 13, 10, 0
