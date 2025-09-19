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
PUSHD	0
MOV	eax, V_buffd
ADD	eax, 8
POP	ebx
MOV	BYTE [eax], bl
SUB	esp, 4
PUSHD	0
L0:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 8
JAE	L1
PUSHD	DWORD [ebp - (-8)]
MOV	eax, DWORD [ebp - (8)]
SHL	eax, 2
MOV	cl, al
SHR	DWORD [esp], cl
MOV	eax, 15
AND	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
MOVZX	eax, BYTE [ebp - (4)]
CMP	eax, 10
JB	L4
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L3
L4:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L3:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	V_buffd
MOV	eax, DWORD [ebp - (8)]
SUB	eax, 7
NEG	eax
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L2:
MOV	eax, DWORD [ebp - (8)]
INC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L0
L1:
MOV	eax, V_buffd
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_cstrub:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
MOV	eax, V_buffb
ADD	eax, 2
POP	ebx
MOV	BYTE [eax], bl
SUB	esp, 4
PUSHD	0
L5:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 2
JAE	L6
MOVZX	eax, BYTE [ebp - (-8)]
PUSHD	eax
MOV	eax, DWORD [ebp - (8)]
SHL	eax, 2
MOV	cl, al
SHR	DWORD [esp], cl
MOV	eax, 15
AND	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
MOVZX	eax, BYTE [ebp - (4)]
CMP	eax, 10
JB	L9
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L8
L9:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L8:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	V_buffb
MOV	eax, DWORD [ebp - (8)]
DEC	eax
NEG	eax
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L7:
MOV	eax, DWORD [ebp - (8)]
INC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L5
L6:
MOV	eax, V_buffb
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
MOV	eax, DWORD [ebp - (-8)]
CMP	eax, 0
JNE	L11
MOVZX	eax, BYTE [V_terminal_color]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
CALL	V_set_terminal_color
ADD	esp, 4
JMP	L10
L11:
MOVZX	eax, BYTE [V_terminal_color]
PUSHD	eax
MOV	eax, 128
OR	DWORD [esp], eax
CALL	V_set_terminal_color
ADD	esp, 4
L10:
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
L12:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757664
JAE	L13
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L14:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L12
L13:
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
L15:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757504
JAE	L16
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 160
MOVZX	eax, WORD [eax]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L17:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L15
L16:
MOV	eax, 1
L18:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757664
JAE	L19
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
L20:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L18
L19:
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
MOVZX	eax, BYTE [ebp - (-20)]
CMP	eax, 0
JNE	L22
MOVZX	eax, BYTE [V_terminal_color]
MOV	BYTE [ebp - (-20)], al
L22:
L21:
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, -1
MOV	eax, 0
SETE	al
CMP	eax, 0
JNE	L27
PUSHD	eax
MOV	eax, DWORD [ebp - (-16)]
CMP	eax, -1
MOV	eax, 0
SETE	al
OR	DWORD [esp], eax
POP	eax
L27:
CMP	eax, 0
JNE	L26
PUSHD	eax
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, 80
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
POP	eax
L26:
CMP	eax, 0
JNE	L25
PUSHD	eax
MOV	eax, DWORD [ebp - (-16)]
CMP	eax, 25
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
POP	eax
L25:
CMP	eax, 0
JE	L24
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
MOVZX	eax, BYTE [eax]
CMP	eax, 10
JE	L29
CMP	eax, 13
JE	L30
CMP	eax, 9
JE	L31
JMP	L32
L29:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L28
L30:
MOV	eax, DWORD [ebp - (-12)]
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
INC	eax
MOV	DWORD [ebp - (16)], eax
JMP	L28
L31:
MOV	eax, DWORD [ebp - (-12)]
ADD	eax, 8
PUSHD	eax
MOV	eax, 4294967288
AND	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, 79
JBE	L34
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (16)]
INC	eax
MOV	DWORD [ebp - (16)], eax
L34:
L33:
JMP	L28
L32:
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
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, 79
JAE	L36
MOV	eax, DWORD [ebp - (-12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L35
L36:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
INC	eax
MOV	DWORD [ebp - (16)], eax
L35:
L28:
MOV	eax, DWORD [ebp - (16)]
CMP	eax, 25
JB	L38
MOV	eax, DWORD [ebp - (16)]
DEC	eax
MOV	DWORD [ebp - (16)], eax
CALL	V_scroll
L38:
L37:
PUSHD	DWORD [ebp - (16)]
PUSHD	DWORD [ebp - (12)]
CALL	V_set_cursor_pos
ADD	esp, 8
JMP	L23
L24:
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
L23:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_printf:
PUSH	ebp
MOV	ebp, esp
PUSHD	1
L39:
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 0
JE	L40
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 37
JNE	L42
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 100
JE	L44
CMP	eax, 99
JE	L45
CMP	eax, 115
JE	L46
JMP	L47
L44:
LEA	eax, [ebp - (-8)]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
CALL	V_cstrud
ADD	esp, 4
PUSHD	eax
CALL	V_printf
ADD	esp, 4
JMP	L43
L45:
LEA	eax, [ebp - (-8)]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
CALL	V_cstrub
ADD	esp, 4
PUSHD	eax
CALL	V_printf
ADD	esp, 4
JMP	L43
L46:
LEA	eax, [ebp - (-8)]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
CALL	V_printf
ADD	esp, 4
JMP	L43
L47:
PUSHD	0
PUSHD	-1
PUSHD	-1
MOV	eax, DWORD [ebp - (-8)]
DEC	eax
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
L43:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L41
L42:
PUSHD	0
PUSHD	-1
PUSHD	-1
PUSHD	DWORD [ebp - (-8)]
CALL	V_putchar
ADD	esp, 16
L41:
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
JMP	L39
L40:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_sleep:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L48:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 3145727
JAE	L49
L50:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L48
L49:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_except_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L51
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
PUSHD	L52
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
PUSHD	L53
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
PUSHD	L54
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
PUSHD	L55
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
PUSHD	L56
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
PUSHD	L57
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
PUSHD	L58
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
L59:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 32
JAE	L60
PUSHD	V_except_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L61:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L59
L60:
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
PUSHD	L62
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
PUSHD	L63
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
PUSHD	L64
CALL	V_printf
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
V_install_irq_interrupts:
PUSH	ebp
MOV	ebp, esp
PUSHD	32
L65:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 40
JAE	L66
PUSHD	V_master_irq_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L67:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L65
L66:
MOV	eax, 40
MOV	DWORD [ebp - (4)], eax
L68:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 48
JAE	L69
PUSHD	V_slave_irq_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L70:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L68
L69:
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
PUSHD	2047
MOV	eax, V_idtr
POP	ebx
MOV	WORD [eax], bx
PUSHD	V_idt
MOV	eax, V_idtr
ADD	eax, 2
POP	ebx
MOV	DWORD [eax], ebx
MOV	eax, V_idtr
lidt [eax]
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_install_interrupt_handler:
PUSH	ebp
MOV	ebp, esp
PUSHD	V_idt
MOV	eax, DWORD [ebp - (-8)]
SHL	eax, 3
ADD	DWORD [esp], eax
PUSHD	DWORD [ebp - (-12)]
MOV	eax, 65535
AND	DWORD [esp], eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	WORD [eax], bx
PUSHD	8
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 2
POP	ebx
MOV	WORD [eax], bx
PUSHD	142
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 5
POP	ebx
MOV	BYTE [eax], bl
MOV	eax, DWORD [ebp - (-12)]
SHR	eax, 16
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 6
POP	ebx
MOV	WORD [eax], bx
PUSHD	0
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 4
POP	ebx
MOV	BYTE [eax], bl
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
PUSHD	L71
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
L72:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 256
JAE	L73
PUSHD	V_generic_interrupt_handler
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L74:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L72
L73:
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
CMP	eax, 1048576
JB	L76
MOV	eax, 1
JMP	@f
L76:
L75:
MOV	eax, DWORD [ebp - (-8)]
SHR	eax, 3
PUSHD	eax
PUSHD	DWORD [ebp - (-8)]
MOV	eax, 3
AND	DWORD [esp], eax
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
CMP	eax, 1048576
JB	L78
MOV	eax, 0
JMP	@f
L78:
L77:
MOV	eax, DWORD [ebp - (-8)]
SHR	eax, 3
PUSHD	eax
PUSHD	DWORD [ebp - (-8)]
MOV	eax, 3
AND	DWORD [esp], eax
POP	eax
MOV	cl, al
MOV	eax, 1
SHL	eax, cl
PUSHD	eax
MOVZX	eax, BYTE [ebp - (-12)]
CMP	eax, 0
JE	L80
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
JMP	L79
L80:
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
L79:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_palloc:
PUSH	ebp
MOV	ebp, esp
PUSHD	1284
MOV	eax, 1280
PUSHD	DWORD [eax]
L81:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 0
JBE	L82
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 16
MOV	eax, DWORD [eax]
CMP	eax, 1
MOV	eax, 0
SETE	al
CMP	eax, 0
JE	L85
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 4
MOV	eax, DWORD [eax]
test	eax, eax
setz	al
and	eax, 0xff
AND	DWORD [esp], eax
POP	eax
L85:
CMP	eax, 0
JE	L84
MOV	eax, DWORD [ebp - (4)]
MOV	eax, DWORD [eax]
SHR	eax, 12
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 8
MOV	eax, DWORD [eax]
SHR	eax, 12
PUSHD	eax
PUSHD	0
L86:
PUSHD	DWORD [ebp - (20)]
MOV	eax, DWORD [ebp - (16)]
CMP	DWORD [esp], eax
LEA	esp, [esp + 4]
JAE	L87
PUSHD	DWORD [ebp - (12)]
MOV	eax, DWORD [ebp - (20)]
ADD	DWORD [esp], eax
PUSHD	DWORD [ebp - (24)]
CALL	V_bitmap_get
ADD	esp, 4
test	eax, eax
setz	al
and	eax, 0xff
CMP	eax, 0
JE	L90
PUSHD	1
PUSHD	DWORD [ebp - (24)]
CALL	V_bitmap_set
ADD	esp, 8
MOV	eax, DWORD [ebp - (24)]
SHL	eax, 12
JMP	@f
L90:
L89:
ADD	esp, 4
L88:
MOV	eax, DWORD [ebp - (20)]
INC	eax
MOV	DWORD [ebp - (20)], eax
JMP	L86
L87:
ADD	esp, 12
L84:
L83:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L81
L82:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_pfree:
PUSH	ebp
MOV	ebp, esp
MOV	eax, DWORD [ebp - (-8)]
SHR	eax, 12
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
PUSHD	1284
MOV	eax, 1280
PUSHD	DWORD [eax]
PUSHD	L91
CALL	V_printf
ADD	esp, 4
L92:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 0
JBE	L93
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
PUSHD	DWORD [eax]
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 4
PUSHD	DWORD [eax]
PUSHD	L94
CALL	V_printf
ADD	esp, 28
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L92
L93:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_fill_bitmap:
PUSH	ebp
MOV	ebp, esp
PUSHD	1284
MOV	eax, 1280
PUSHD	DWORD [eax]
PUSHD	0
L95:
MOV	eax, DWORD [ebp - (12)]
CMP	eax, 131072
JAE	L96
PUSHD	255
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (12)]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L97:
MOV	eax, DWORD [ebp - (12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L95
L96:
L98:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 0
JBE	L99
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 16
MOV	eax, DWORD [eax]
CMP	eax, 1
MOV	eax, 0
SETE	al
CMP	eax, 0
JE	L102
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 4
MOV	eax, DWORD [eax]
test	eax, eax
setz	al
and	eax, 0xff
AND	DWORD [esp], eax
POP	eax
L102:
CMP	eax, 0
JE	L101
MOV	eax, DWORD [ebp - (4)]
MOV	eax, DWORD [eax]
SHR	eax, 12
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 8
MOV	eax, DWORD [eax]
SHR	eax, 12
PUSHD	eax
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
L103:
PUSHD	DWORD [ebp - (12)]
MOV	eax, DWORD [ebp - (20)]
CMP	DWORD [esp], eax
LEA	esp, [esp + 4]
JAE	L104
PUSHD	0
PUSHD	DWORD [ebp - (16)]
MOV	eax, DWORD [ebp - (12)]
ADD	DWORD [esp], eax
CALL	V_bitmap_set
ADD	esp, 8
L105:
MOV	eax, DWORD [ebp - (12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L103
L104:
ADD	esp, 8
L101:
L100:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L98
L99:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
L106:
MOV	eax, DWORD [ebp - (12)]
CMP	eax, 256
JAE	L107
PUSHD	1
PUSHD	DWORD [ebp - (12)]
CALL	V_bitmap_set
ADD	esp, 8
L108:
MOV	eax, DWORD [ebp - (12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L106
L107:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_setup_memory:
PUSH	ebp
MOV	ebp, esp
CALL	V_fill_bitmap
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
PUSHD	L109
CALL	V_printf
ADD	esp, 8
MOV	eax, DWORD [ebp - (-12)]
CALL	eax
PUSHD	2
CALL	V_set_terminal_color
ADD	esp, 4
PUSHD	L110
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
PUSHD	L111
CALL	V_printf
ADD	esp, 4
PUSHD	V_setup_interrupts
PUSHD	L112
CALL	V_init_component
ADD	esp, 8
PUSHD	V_setup_memory
PUSHD	L113
CALL	V_init_component
ADD	esp, 8
PUSHD	L114
CALL	V_printf
ADD	esp, 4
CALL	V_enum_memory_map
CALL	V_palloc
PUSHD	eax
CALL	V_palloc
PUSHD	eax
PUSHD	DWORD [ebp - (8)]
PUSHD	DWORD [ebp - (4)]
PUSHD	L115
CALL	V_printf
ADD	esp, 12
PUSHD	1
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	0
CALL	V_bitmap_get
ADD	esp, 4
PUSHD	eax
PUSHD	L116
CALL	V_printf
ADD	esp, 12
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
PUSHD	L117
CALL	V_printf
ADD	esp, 12
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
MOVZX	eax, BYTE [ebp - (24)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (20)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (16)]
PUSHD	eax
MOVZX	eax, BYTE [ebp - (12)]
PUSHD	eax
PUSHD	L118
CALL	V_printf
ADD	esp, 20
PUSHD	255
PUSHD	253
CALL	V_PIC_mask
ADD	esp, 8
sti
PUSHD	L119
CALL	V_printf
ADD	esp, 4
L120:
hlt
JMP	L120
L121:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_buffd rb 9
V_buffb rb 3
V_terminal_color db 15
L51 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L52 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L53 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L54 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L55 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L56 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L57 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L58 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L62 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 109, 97, 115, 116, 101, 114, 41, 13, 10, 0
L63 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 115, 108, 97, 118, 101, 41, 32, 13, 10, 0
L64 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 37, 99, 13, 10, 0
align 16
V_idt rb 2048
V_idtr rb 6
L71 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
V_memory_bitmap rb 131072
L91 db 66, 97, 115, 101, 32, 65, 100, 100, 114, 101, 115, 115, 9, 9, 76, 101, 110, 103, 116, 104, 9, 9, 9, 84, 121, 112, 101, 9, 9, 65, 99, 112, 105, 32, 97, 116, 116, 114, 105, 98, 115, 13, 10, 0
L94 db 37, 100, 37, 100, 9, 37, 100, 37, 100, 9, 37, 100, 9, 37, 100, 13, 10, 0
L109 db 32, 43, 32, 37, 115, 0
L110 db 32, 91, 32, 79, 75, 32, 93, 13, 10, 0
L111 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L112 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 32, 0
L113 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 0
L114 db 84, 101, 115, 116, 105, 110, 103, 32, 109, 101, 109, 111, 114, 121, 58, 13, 10, 0
L115 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 49, 48, 48, 48, 48, 48, 32, 48, 48, 49, 48, 49, 48, 48, 48, 58, 32, 37, 100, 32, 37, 100, 13, 10, 0
L116 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 49, 32, 48, 49, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L117 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L118 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 49, 32, 48, 49, 32, 48, 49, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 32, 37, 99, 32, 37, 99, 13, 10, 0
L119 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
