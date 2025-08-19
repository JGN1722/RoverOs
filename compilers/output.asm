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
PUSHD	V_buffd
MOV	eax, 8
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
SUB	esp, 4
PUSHD	0
L0:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 9
JE	L1
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
JB	L3
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L2
L3:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L2:
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
PUSHD	V_buffb
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
SUB	esp, 4
PUSHD	0
L4:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 2
JE	L5
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
JB	L7
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L6
L7:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L6:
MOVZX	eax, BYTE [ebp - (4)]
PUSHD	eax
PUSHD	V_buffb
MOV	eax, DWORD [ebp - (8)]
SUB	eax, 1
NEG	eax
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
MOV	eax, DWORD [ebp - (8)]
INC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L4
L5:
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
JNE	L9
MOVZX	eax, BYTE[V_terminal_color]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
CALL	V_set_terminal_color
ADD	esp, 4
JMP	L8
L9:
MOVZX	eax, BYTE[V_terminal_color]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
POP	eax
ADD	eax, 128
PUSHD	eax
CALL	V_set_terminal_color
ADD	esp, 4
L8:
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
L10:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757664
JAE	L11
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	DWORD [eax], ebx
L12:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L10
L11:
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
L13:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757504
JAE	L14
MOV	eax, DWORD [ebp - (4)]
ADD	eax, 160
MOVZX	eax, WORD [eax]
PUSHD	eax
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	DWORD [eax], ebx
L15:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L13
L14:
MOV	eax, 1
L16:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 757664
JAE	L17
PUSHD	3872
MOV	eax, DWORD [ebp - (4)]
POP	ebx
MOV	DWORD [eax], ebx
L18:
PUSHD	DWORD [ebp - (4)]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L16
L17:
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
MOVZX	eax, BYTE [ebp - (-20)]
CMP	eax, 0
JNE	L20
MOVZX	eax, BYTE[V_terminal_color]
MOV	BYTE [ebp - (-20)], al
L20:
L19:
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, -1
MOV	eax, 0
SETE	al
PUSHD	eax
MOV	eax, DWORD [ebp - (-16)]
CMP	eax, -1
MOV	eax, 0
SETE	al
OR	DWORD [esp], eax
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, 80
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
MOV	eax, DWORD [ebp - (-16)]
CMP	eax, 25
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
POP	eax
CMP	eax, 0
JE	L22
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
JE	L24
CMP	eax, 13
JE	L25
CMP	eax, 9
JE	L26
JMP	L27
L24:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L23
L25:
MOV	eax, DWORD [ebp - (-12)]
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
ADD	eax, 1
MOV	DWORD [ebp - (16)], eax
JMP	L23
L26:
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
JBE	L29
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (16)]
INC	eax
MOV	DWORD [ebp - (16)], eax
L29:
L28:
JMP	L23
L27:
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
MOV	DWORD [eax], ebx
MOV	eax, DWORD [ebp - (-12)]
CMP	eax, 79
JAE	L31
MOV	eax, DWORD [ebp - (-12)]
ADD	eax, 1
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
MOV	DWORD [ebp - (16)], eax
JMP	L30
L31:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, DWORD [ebp - (-16)]
ADD	eax, 1
MOV	DWORD [ebp - (16)], eax
L30:
L23:
MOV	eax, DWORD [ebp - (16)]
CMP	eax, 25
JB	L33
MOV	eax, DWORD [ebp - (16)]
DEC	eax
MOV	DWORD [ebp - (16)], eax
CALL	V_scroll
L33:
L32:
PUSHD	DWORD [ebp - (16)]
PUSHD	DWORD [ebp - (12)]
CALL	V_set_cursor_pos
ADD	esp, 8
JMP	L21
L22:
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
MOV	DWORD [eax], ebx
L21:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_printf:
PUSH	ebp
MOV	ebp, esp
PUSHD	1
L34:
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 0
JE	L35
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 37
JNE	L37
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
MOV	eax, DWORD [ebp - (-8)]
MOVZX	eax, BYTE [eax]
CMP	eax, 100
JE	L39
CMP	eax, 99
JE	L40
CMP	eax, 115
JE	L41
JMP	L42
L39:
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
JMP	L38
L40:
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
JMP	L38
L41:
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
JMP	L38
L42:
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
L38:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L36
L37:
PUSHD	0
PUSHD	-1
PUSHD	-1
PUSHD	DWORD [ebp - (-8)]
CALL	V_putchar
ADD	esp, 16
L36:
MOV	eax, DWORD [ebp - (-8)]
INC	eax
MOV	DWORD [ebp - (-8)], eax
JMP	L34
L35:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_sleep:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L43:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 3145727
JAE	L44
L45:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L43
L44:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_except_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L46
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
PUSHD	L47
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
PUSHD	L48
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
PUSHD	L49
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
PUSHD	L50
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
PUSHD	L51
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
PUSHD	L52
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
PUSHD	L53
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
L54:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 32
JAE	L55
PUSHD	V_except_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L56:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L54
L55:
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
PUSHD	L57
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
PUSHD	L58
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
PUSHD	L59
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
L60:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 40
JAE	L61
PUSHD	V_master_irq_default
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L62:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L60
L61:
PUSHD	40
L63:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 48
JAE	L64
PUSHD	V_slave_irq_default
PUSHD	DWORD [ebp - (8)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L65:
MOV	eax, DWORD [ebp - (8)]
INC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L63
L64:
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
IMUL	eax, 8
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
PUSHD	L66
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
L67:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 256
JAE	L68
PUSHD	V_generic_interrupt_handler
PUSHD	DWORD [ebp - (4)]
CALL	V_install_interrupt_handler
ADD	esp, 8
L69:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L67
L68:
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
JE	L71
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
JMP	L70
L71:
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
L70:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_palloc:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L72:
MOV	eax, DWORD [ebp - (4)]
CMP	eax, 1048576
JAE	L73
PUSHD	DWORD [ebp - (4)]
CALL	V_bitmap_get
ADD	esp, 4
test	eax, eax
setz	al
and	eax, 0xff
CMP	eax, 0
JE	L76
PUSHD	1
PUSHD	DWORD [ebp - (4)]
CALL	V_bitmap_set
ADD	esp, 8
MOV	eax, DWORD [ebp - (4)]
IMUL	eax, 4096
JMP	@f
L76:
L75:
L74:
MOV	eax, DWORD [ebp - (4)]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L72
L73:
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
PUSHD	L77
CALL	V_printf
ADD	esp, 4
L78:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 0
JBE	L79
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
PUSHD	L80
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
JMP	L78
L79:
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
L81:
MOV	eax, DWORD [ebp - (12)]
CMP	eax, 1310
JAE	L82
PUSHD	255
PUSHD	V_memory_bitmap
MOV	eax, DWORD [ebp - (12)]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L83:
MOV	eax, DWORD [ebp - (12)]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L81
L82:
L84:
MOV	eax, DWORD [ebp - (8)]
CMP	eax, 0
JBE	L85
PUSHD	DWORD [ebp - (4)]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, DWORD [ebp - (8)]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L84
L85:
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
PUSHD	L86
CALL	V_printf
ADD	esp, 4
MOV	eax, DWORD [ebp - (-12)]
CALL	eax
PUSHD	2
CALL	V_set_terminal_color
ADD	esp, 4
PUSHD	L87
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
PUSHD	L88
CALL	V_printf
ADD	esp, 4
PUSHD	V_setup_interrupts
PUSHD	L89
CALL	V_init_component
ADD	esp, 8
PUSHD	V_setup_memory
PUSHD	L90
CALL	V_init_component
ADD	esp, 8
PUSHD	L91
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
PUSHD	L92
CALL	V_printf
ADD	esp, 4
CALL	V_palloc
PUSHD	eax
CALL	V_palloc
PUSHD	eax
PUSHD	L93
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
PUSHD	L94
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
PUSHD	L95
CALL	V_printf
ADD	esp, 4
PUSHD	255
PUSHD	253
CALL	V_PIC_mask
ADD	esp, 8
sti
PUSHD	L96
CALL	V_printf
ADD	esp, 4
L97:
hlt
JMP	L97
L98:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_buffd rb 9
V_buffb rb 3
V_terminal_color db 15
L46 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L47 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L48 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L49 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L50 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L51 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L52 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L53 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L57 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 109, 97, 115, 116, 101, 114, 41, 13, 10, 0
L58 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 115, 108, 97, 118, 101, 41, 32, 13, 10, 0
L59 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 37, 99, 13, 10, 0
V_idt rb 2048
V_idtr rb 6
L66 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
V_memory_bitmap rb 1310
L77 db 66, 97, 115, 101, 32, 65, 100, 100, 114, 101, 115, 115, 9, 9, 76, 101, 110, 103, 116, 104, 9, 9, 9, 84, 121, 112, 101, 9, 9, 65, 99, 112, 105, 32, 97, 116, 116, 114, 105, 98, 115, 13, 10, 0
L80 db 37, 100, 37, 100, 9, 37, 100, 37, 100, 9, 37, 100, 9, 37, 100, 13, 10, 0
L86 db 32, 43, 32, 37, 115, 0
L87 db 32, 91, 32, 79, 75, 32, 93, 13, 10, 0
L88 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L89 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 32, 0
L90 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 0
L91 db 84, 101, 115, 116, 105, 110, 103, 32, 109, 101, 109, 111, 114, 121, 58, 13, 10, 0
L92 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 63, 32, 48, 49, 32, 48, 49, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 32, 37, 99, 32, 37, 99, 13, 10, 0
L93 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 48, 48, 49, 48, 48, 48, 32, 48, 48, 48, 48, 48, 48, 48, 48, 58, 32, 37, 100, 32, 37, 100, 13, 10, 0
L94 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 49, 32, 48, 49, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L95 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L96 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
