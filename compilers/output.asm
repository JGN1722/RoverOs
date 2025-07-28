use32
org 32768
JMP V_main
V_inb:
PUSH	ebp
MOV	ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in al, dx
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_inw:
PUSH	ebp
MOV	ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in ax, dx
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_ind:
PUSH	ebp
MOV	ebp, esp
MOV edx, DWORD [ebp + 8]
in eax, dx
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_outb:
PUSH	ebp
MOV	ebp, esp
MOV eax, DWORD [ebp + 12]
MOV edx, DWORD [ebp + 8]
out dx, al
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_outw:
PUSH	ebp
MOV	ebp, esp
MOV eax, DWORD [ebp + 12]
MOV edx, DWORD [ebp + 8]
out dx, ax
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_outd:
PUSH	ebp
MOV	ebp, esp
MOV eax, DWORD [ebp + 12]
MOV edx, DWORD [ebp + 8]
out dx, eax
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_cstrud:
PUSH	ebp
MOV	ebp, esp

	mov ecx, 0
	
	.fill_next_char:
	cmp ecx, 8	; I want to print 8 nibbles / 4 bytes / 1 DWORD
	je .end_filling
	push ecx	; ecx might be modified, so save it
	
			;get the nibble to print in al-low
	mov eax, DWORD [ebp + 8]
	shl ecx, 2
	shr eax, cl
	and eax, 15
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 10	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,10
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
MOV	esp, ebp
POP	ebp
RET	0
V_cstrudx:
PUSH	ebp
MOV	ebp, esp

	mov ecx, 0
	
	.fill_next_char:
	cmp ecx, 8	; I want to print 8 nibbles / 4 bytes / 1 DWORD
	je .end_filling
	push ecx	; ecx might be modified, so save it
	
			;get the nibble to print in al-low
	mov eax, DWORD [ebp + 8]
	shl ecx, 2
	shr eax, cl
	and eax, 15
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 10	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,10
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
MOV	esp, ebp
POP	ebp
RET	0
V_cstrub:
PUSH	ebp
MOV	ebp, esp

	mov ecx, 0
	
	.fill_next_char:
	cmp ecx, 2	; I want to print 8 nibbles / 4 bytes / 1 DWORD
	je .end_filling
	push ecx	; ecx might be modified, so save it
	
			;get the nibble to print in al-low
	mov eax, DWORD [ebp + 8]
	shl ecx, 2
	shr eax, cl
	and eax, 15
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 10	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,10
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
MOV	esp, ebp
POP	ebp
RET	0
V_init_vga:
PUSH	ebp
MOV	ebp, esp
CALL	V_clear_screen
PUSHD	15
CALL	V_set_terminal_color
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_terminal_color:
PUSH	ebp
MOV	ebp, esp
MOVZX	eax, BYTE [ebp - (-8)]
MOV	BYTE [V_terminal_color], al
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_blinking:
PUSH	ebp
MOV	ebp, esp
CMP	DWORD [ebp - (-8)], 0
JNE	L1
MOVZX	eax, BYTE[V_terminal_color]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
CALL	V_set_terminal_color
ADD	esp, 4
JMP	L0
L1:
MOVZX	eax, BYTE[V_terminal_color]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
POP	eax
ADD	eax, 128
PUSHD	eax
CALL	V_set_terminal_color
ADD	esp, 4
L0:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_cursor_pos:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-12)]
IMUL	eax, 80
PUSHD	eax
MOV	eax, DWORD [ebp - (-8)]
ADD	DWORD [esp], eax
PUSHD	14
PUSHD	980
CALL	V_outb
ADD	esp, 8
MOVZX	eax, WORD [ebp - (4)]
SHR	eax, 8
PUSHD	eax
PUSHD	981
CALL	V_outb
ADD	esp, 8
PUSHD	15
PUSHD	980
CALL	V_outb
ADD	esp, 8
MOVZX	eax, WORD [ebp - (4)]
PUSHD	eax
PUSHD	981
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_get_cursor_pos:
PUSH	ebp
MOV	ebp, esp
SUB	esp, 4
SUB	esp, 4
PUSHD	14
PUSHD	980
CALL	V_outb
ADD	esp, 8
PUSHD	981
CALL	V_inb
ADD	esp, 4
MOV	BYTE [ebp - (4)], al
PUSHD	15
PUSHD	980
CALL	V_outb
ADD	esp, 8
PUSHD	981
CALL	V_inb
ADD	esp, 4
MOV	BYTE [ebp - (8)], al
MOVZX	eax, BYTE [ebp - (4)]
SHL	eax, 8
PUSHD	eax
MOVZX	eax, BYTE [ebp - (8)]
ADD	DWORD [esp], eax
POP	eax
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_clear_screen:
PUSH	ebp
MOV	ebp, esp
PUSHD	753664
L2:
CMP	DWORD [ebp - (4)], 757664
JAE	L3
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L4:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L2
L3:
PUSHD	0
PUSHD	0
CALL	V_set_cursor_pos
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_scroll:
PUSH	ebp
MOV	ebp, esp
PUSHD	753664
MOV	eax, 1
L5:
CMP	DWORD [ebp - (4)], 757504
JAE	L6
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 160
MOVZX	eax, WORD [eax]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L7:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L5
L6:
MOV	eax, 1
L8:
CMP	DWORD [ebp - (4)], 757664
JAE	L9
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L10:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L8
L9:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_putchar:
PUSH	ebp
MOV	ebp, esp
SUB	esp, 4
SUB	esp, 4
SUB	esp, 4
SUB	esp, 4
SUB	esp, 4
SUB	esp, 4
SUB	esp, 4
CMP	BYTE [ebp - (-20)], 0
JNE	L12
MOVZX	eax, BYTE[V_terminal_color]
MOV	BYTE [ebp - (-20)], al
L12:
L11:
CMP	DWORD [ebp - (-12)], -1
MOV	eax, 0
SETE	al
PUSHD	eax
CMP	DWORD [ebp - (-16)], -1
MOV	eax, 0
SETE	al
OR	DWORD [esp], eax
CMP	DWORD [ebp - (-12)], 80
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
CMP	DWORD [ebp - (-16)], 25
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
POP	eax
CMP	eax, 0
JE	L14
CALL	V_get_cursor_pos
MOV	DWORD [ebp - (8)], eax
MOV	eax, DWORD [ebp - (8)]
MOV	ebx, 80
XOR	edx, edx
IDIV	ebx
MOV	eax, edx
MOV	DWORD [ebp - (-12)], eax
PUSHD	DWORD [ebp - (8)]
MOV	eax, DWORD [ebp - (-12)]
SUB	DWORD [esp], eax
POP	eax
MOV	ebx, 80
XOR	edx, edx
IDIV	ebx
MOV	DWORD [ebp - (-16)], eax
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 13
JNE	L16
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L15
L16:
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 10
JNE	L17
MOV	eax, DWORD [ebp - (-12)]
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
ADD	eax, 1
MOV	DWORD [ebp - (16)], eax
JMP	L15
L17:
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 9
JNE	L18
MOV	eax, DWORD [ebp - (-12)]
ADD	eax, 8
PUSHD	eax
MOV	eax, 4294967288
AND	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
CMP	DWORD [ebp - (-12)], 79
JBE	L20
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (16)]
INC	eax
MOV	DWORD [ebp - (16)], eax
L20:
L19:
JMP	L15
L18:
MOV	eax, DWORD [ebp - (-16)]
IMUL	eax, 80
PUSHD	eax
MOV	eax, DWORD [ebp - (-12)]
ADD	DWORD [esp], eax
POP	eax
SHL	eax, 1
ADD	eax, 753664
MOV	DWORD [ebp - (4)], eax
MOVZX	eax, BYTE [ebp - (-20)]
SHL	eax, 8
PUSHD	eax
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
ADD	DWORD [esp], eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
CMP	DWORD [ebp - (-12)], 79
JAE	L22
MOV	eax, DWORD [ebp - (-12)]
ADD	eax, 1
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L21
L22:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
ADD	eax, 1
MOV	DWORD [ebp - (16)], eax
L21:
L15:
CMP	DWORD [ebp - (16)], 25
JB	L24
MOV	eax, DWORD [ebp - (16)]
DEC	eax
MOV	DWORD [ebp - (16)], eax
CALL	V_scroll
L24:
L23:
PUSHD	DWORD [ebp - (16)]
PUSHD	DWORD [ebp - (12)]
CALL	V_set_cursor_pos
ADD	esp, 8
JMP	L13
L14:
MOV	eax, DWORD [ebp - (-16)]
IMUL	eax, 80
PUSHD	eax
MOV	eax, DWORD [ebp - (-12)]
ADD	DWORD [esp], eax
POP	eax
SHL	eax, 1
ADD	eax, 753664
MOV	DWORD [ebp - (4)], eax
MOVZX	eax, BYTE [ebp - (-20)]
SHL	eax, 8
PUSHD	eax
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
ADD	DWORD [esp], eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L13:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_printf:
PUSH	ebp
MOV	ebp, esp
PUSHD	1
L25:
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 0
JE	L26
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 37
JNE	L28
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 100
JNE	L30
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
IMUL	eax, 4
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
CALL	V_cstrud
ADD	esp, 4
PUSHD	eax
CALL	V_printf
ADD	esp, 4
JMP	L29
L30:
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 99
JNE	L31
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
IMUL	eax, 4
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
CALL	V_cstrub
ADD	esp, 4
PUSHD	eax
CALL	V_printf
ADD	esp, 4
JMP	L29
L31:
MOV	eax, DWORD [ebp - (-8)]
CMP	BYTE [eax], 115
JNE	L32
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
IMUL	eax, 4
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
CALL	V_printf
ADD	esp, 4
JMP	L29
L32:
PUSHD	0
PUSHD	-1
PUSHD	-1
MOV	eax, DWORD [ebp - (-8)]
SUB	eax, 1
PUSHD	eax
CALL	V_putchar
ADD	esp, 16
PUSHD	0
PUSHD	-1
PUSHD	-1
PUSHD	DWORD [ebp - (-8)]
CALL	V_putchar
ADD	esp, 16
MOV	eax, DWORD [ebp - (4)]
DEC	eax
MOV	DWORD [ebp - (4)], eax
L29:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L27
L28:
PUSHD	0
PUSHD	-1
PUSHD	-1
PUSHD	DWORD [ebp - (-8)]
CALL	V_putchar
ADD	esp, 16
L27:
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
JMP	L25
L26:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_sleep:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L33:
CMP	DWORD [ebp - (4)], 3145727
JAE	L34
L35:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L33
L34:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_except_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L36
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_null_div:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L37
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_overflow:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L38
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_double_fault:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L39
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_ss_fault:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L40
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_gpf:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L41
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_page_fault:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L42
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_except_float:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L43
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_install_exception_interrupts:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L44:
CMP	DWORD [ebp - (4)], 32
JAE	L45
PUSHD	V_except_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L46:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L44
L45:
PUSHD	V_except_null_div
PUSHD	0
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_overflow
PUSHD	4
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_double_fault
PUSHD	8
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_ss_fault
PUSHD	12
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_gpf
PUSHD	13
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_page_fault
PUSHD	14
CALL	V_install_interrupt_handler
ADD	esp, 8
PUSHD	V_except_float
PUSHD	16
CALL	V_install_interrupt_handler
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_master_irq_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L47
CALL	V_printf
ADD	esp, 4
PUSHD	32
PUSHD	32
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_slave_irq_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L48
CALL	V_printf
ADD	esp, 4
PUSHD	32
PUSHD	160
CALL	V_outb
ADD	esp, 8
PUSHD	32
PUSHD	32
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_keyboard_handler:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	96
CALL	V_inb
ADD	esp, 4
PUSHD	eax
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
CALL	V_set_terminal_color
ADD	esp, 4
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	L49
CALL	V_printf
ADD	esp, 4
PUSHD	32
PUSHD	32
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_install_irq_interrupts:
PUSH	ebp
MOV	ebp, esp
PUSHD	32
L50:
CMP	DWORD [ebp - (4)], 40
JAE	L51
PUSHD	V_master_irq_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L52:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L50
L51:
PUSHD	40
L53:
CMP	DWORD [ebp - (8)], 48
JAE	L54
PUSHD	V_slave_irq_default
PUSHD	DWORD [ebp - (8)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L55:
MOV	eax, DWORD [ebp - (8)]
INC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L53
L54:
PUSHD	V_keyboard_handler
PUSHD	33
CALL	V_install_interrupt_handler
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_build_idt:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L56:
CMP	DWORD [ebp - (4)], 256
JAE	L57
PUSHD	0
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	BYTE [eax], bl
L58:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L56
L57:
PUSHD	2048
PUSHD	2047
MOV	eax, DWORD [ebp - (8)]
POP	ebx
MOV	WORD [eax], bx
PUSHD	0
MOV	eax, DWORD [ebp - (8)]
ADD	eax, 2
POP	ebx
MOV	DWORD [eax], ebx
MOV	eax, 2048
lidt [eax]
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_install_interrupt_handler:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-8)]
SHL	eax, 3
ADD	eax, 0
PUSHD	eax
PUSHD	DWORD [ebp - (-12)]
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
PUSHD	8
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
POP	ebx
MOV	WORD [eax], bx
PUSHD	36352
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
POP	ebx
MOV	WORD [eax], bx
MOV	eax, DWORD [ebp - (-12)]
SHR	eax, 16
PUSHD	eax
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
POP	ebx
MOV	WORD [eax], bx
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_PIC_remap:
PUSH	ebp
MOV	ebp, esp
SUB	esp, 4
SUB	esp, 4
PUSHD	33
CALL	V_inb
ADD	esp, 4
MOV	BYTE [ebp - (4)], al
PUSHD	161
CALL	V_inb
ADD	esp, 4
MOV	BYTE [ebp - (8)], al
PUSHD	17
PUSHD	32
CALL	V_outb
ADD	esp, 8
PUSHD	17
PUSHD	160
CALL	V_outb
ADD	esp, 8
PUSHD	DWORD [ebp - (-8)]
PUSHD	33
CALL	V_outb
ADD	esp, 8
PUSHD	DWORD [ebp - (-12)]
PUSHD	161
CALL	V_outb
ADD	esp, 8
PUSHD	4
PUSHD	33
CALL	V_outb
ADD	esp, 8
PUSHD	2
PUSHD	161
CALL	V_outb
ADD	esp, 8
PUSHD	1
PUSHD	33
CALL	V_outb
ADD	esp, 8
PUSHD	1
PUSHD	161
CALL	V_outb
ADD	esp, 8
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	33
CALL	V_outb
ADD	esp, 8
MOVZX	eax, BYTE [ebp - (8)]
PUSHD	eax
PUSHD	161
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_PIC_mask:
PUSH	ebp
MOV	ebp, esp
MOVZX	eax, BYTE [ebp - (-8)]
PUSHD	eax
PUSHD	33
CALL	V_outb
ADD	esp, 8
MOVZX	eax, BYTE [ebp - (-12)]
PUSHD	eax
PUSHD	161
CALL	V_outb
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_generic_interrupt_handler:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L59
CALL	V_printf
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
POPAD
IRET
V_install_generic_interrupt_handler:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L60:
CMP	DWORD [ebp - (4)], 256
JAE	L61
PUSHD	V_generic_interrupt_handler
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L62:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L60
L61:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_setup_interrupts:
PUSH	ebp
MOV	ebp, esp
CALL	V_build_idt
CALL	V_install_generic_interrupt_handler
CALL	V_install_exception_interrupts
CALL	V_install_irq_interrupts
PUSHD	40
PUSHD	32
CALL	V_PIC_remap
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_bitmap_get:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-8)]
MOV	ebx, 8
XOR	edx, edx
IDIV	ebx
PUSHD	eax
MOV	eax, DWORD [ebp - (-8)]
MOV	ebx, 8
XOR	edx, edx
IDIV	ebx
PUSHD	edx
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (4)]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (8)]
MOV	cl, al
MOV	eax, 1
SHL	eax, cl
AND	DWORD [esp], eax
POP	eax
CMP	eax, 0
MOV	eax, 0
SETNE	al
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_bitmap_set:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-8)]
MOV	ebx, 8
XOR	edx, edx
IDIV	ebx
PUSHD	eax
MOV	eax, DWORD [ebp - (-8)]
MOV	ebx, 8
XOR	edx, edx
IDIV	ebx
MOV	eax, edx
MOV	cl, al
MOV	eax, 1
SHL	eax, cl
PUSHD	eax
CMP	BYTE [ebp - (-12)], 0
JE	L64
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (4)]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (8)]
OR	DWORD [esp], eax
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (4)]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
JMP	L63
L64:
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (4)]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (8)]
NOT	eax
AND	DWORD [esp], eax
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (4)]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L63:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_palloc:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L65:
CMP	DWORD [ebp - (4)], 10485
JAE	L66
PUSHD	DWORD [ebp - (4)]
CALL	V_bitmap_get
ADD	esp, 4
CMP	eax, 0
JNE	L69
PUSHD	1
PUSHD	DWORD [ebp - (4)]
CALL	V_bitmap_set
ADD	esp, 8
MOV	eax, DWORD [ebp - (4)]
IMUL	eax, 4096
JMP	@f
L69:
L68:
L67:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L65
L66:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_pfree:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-8)]
MOV	ebx, 4096
XOR	edx, edx
IDIV	ebx
PUSHD	eax
PUSHD	0
PUSHD	DWORD [ebp - (4)]
CALL	V_bitmap_set
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_enum_memory_map:
PUSH	ebp
MOV	ebp, esp
PUSHD	2058
MOV	eax, 2054
PUSHD	DWORD [eax]
PUSHD	L70
CALL	V_printf
ADD	esp, 4
L71:
CMP	DWORD [ebp - (8)], 0
JBE	L72
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 20
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 16
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 8
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 12
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 0
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 4
PUSHD	DWORD [eax]
PUSHD	L73
CALL	V_printf
ADD	esp, 4
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L71
L72:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_fill_bitmap:
PUSH	ebp
MOV	ebp, esp
PUSHD	2058
MOV	eax, 2054
PUSHD	DWORD [eax]
PUSHD	0
L74:
CMP	DWORD [ebp - (12)], 1310
JAE	L75
PUSHD	255
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (12)]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L76:
MOV	eax, DWORD [ebp - (12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L74
L75:
L77:
CMP	DWORD [ebp - (8)], 0
JBE	L78
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L77
L78:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_setup_memory:
PUSH	ebp
MOV	ebp, esp
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_init_component:
PUSH	ebp
MOV	ebp, esp
PUSHD	15
CALL	V_set_terminal_color
ADD	esp, 4
PUSHD	DWORD [ebp - (-8)]
PUSHD	L79
CALL	V_printf
ADD	esp, 4
MOV	eax, DWORD [ebp - (-12)]
CALL	eax
PUSHD	2
CALL	V_set_terminal_color
ADD	esp, 4
PUSHD	L80
CALL	V_printf
ADD	esp, 4
PUSHD	15
CALL	V_set_terminal_color
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_main:
PUSH	ebp
MOV	ebp, esp
CALL	V_init_vga
PUSHD	L81
CALL	V_printf
ADD	esp, 4
PUSHD	V_setup_interrupts
PUSHD	L82
CALL	V_init_component
ADD	esp, 8
PUSHD	V_setup_memory
PUSHD	L83
CALL	V_init_component
ADD	esp, 8
PUSHD	L84
CALL	V_printf
ADD	esp, 4
CALL	V_enum_memory_map
PUSHD	42
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	1
PUSHD	42
CALL	V_bitmap_set
ADD	esp, 8
PUSHD	42
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	1
PUSHD	42
CALL	V_bitmap_set
ADD	esp, 8
PUSHD	42
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	0
PUSHD	42
CALL	V_bitmap_set
ADD	esp, 8
PUSHD	42
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
MOVZX	eax, BYTE [ebp - (16)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (12)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (8)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	L85
CALL	V_printf
ADD	esp, 4
CALL	V_palloc
PUSHD	eax
CALL	V_palloc
PUSHD	eax
PUSHD	L86
CALL	V_printf
ADD	esp, 4
PUSHD	1
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	0
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	L87
CALL	V_printf
ADD	esp, 4
PUSHD	0
CALL	V_pfree
ADD	esp, 4
PUSHD	4096
CALL	V_pfree
ADD	esp, 4
PUSHD	1
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	0
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	L88
CALL	V_printf
ADD	esp, 4
PUSHD	255
PUSHD	253
CALL	V_PIC_mask
ADD	esp, 8
sti
PUSHD	L89
CALL	V_printf
ADD	esp, 4
L90:
hlt
JMP	L90
L91:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_terminal_color rb 1
L36 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L37 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L38 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L39 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L40 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L41 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L42 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L43 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L47 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 109, 97, 115, 116, 101, 114, 41, 13, 10, 0
L48 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 115, 108, 97, 118, 101, 41, 32, 13, 10, 0
L49 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 37, 99, 13, 10, 0
L59 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
V_memory_bitmap rb 1310
L70 db 66, 97, 115, 101, 32, 65, 100, 100, 114, 101, 115, 115, 9, 9, 76, 101, 110, 103, 116, 104, 9, 9, 9, 84, 121, 112, 101, 9, 9, 65, 99, 112, 105, 32, 97, 116, 116, 114, 105, 98, 115, 13, 10, 0
L73 db 37, 100, 37, 100, 9, 37, 100, 37, 100, 9, 37, 100, 9, 37, 100, 13, 10, 0
L79 db 32, 43, 32, 37, 115, 0
L80 db 32, 91, 32, 79, 75, 32, 93, 13, 10, 0
L81 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L82 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 32, 0
L83 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 0
L84 db 84, 101, 115, 116, 105, 110, 103, 32, 109, 101, 109, 111, 114, 121, 58, 13, 10, 0
L85 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 63, 48, 49, 48, 49, 48, 48, 58, 32, 37, 99, 37, 99, 37, 99, 37, 99, 13, 10, 0
L86 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 48, 48, 49, 48, 48, 48, 32, 48, 48, 48, 48, 48, 48, 48, 48, 58, 32, 37, 100, 32, 37, 100, 13, 10, 0
L87 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 49, 32, 48, 49, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L88 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L89 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
