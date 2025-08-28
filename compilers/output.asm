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
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
CMP	eax, 8
JAE	L1
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
SHL	eax, 2
MOV	cl, al
SHR	DWORD [esp], cl
MOV	eax, 15
AND	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
CMP	eax, 10
JB	L4
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L3
L4:
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L3:
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	V_buffd
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
SUB	eax, 7
NEG	eax
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L2:
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
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
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
CMP	eax, 2
JAE	L6
MOV	eax, ebp
SUB	eax, -8
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
SHL	eax, 2
MOV	cl, al
SHR	DWORD [esp], cl
MOV	eax, 15
AND	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
CMP	eax, 10
JB	L9
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 55
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
JMP	L8
L9:
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 48
ADD	DWORD [esp], eax
POP	eax
MOV	BYTE [ebp - (4)], al
L8:
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	V_buffb
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
DEC	eax
NEG	eax
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L7:
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
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
MOV	eax, V_clear_screen
CALL	eax
PUSHD	15
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_terminal_color:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -8
MOVZX	eax, BYTE [eax]
MOV	BYTE [V_terminal_color], al
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_blinking:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
CMP	eax, 0
JNE	L11
MOV	eax, V_terminal_color
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
JMP	L10
L11:
MOV	eax, V_terminal_color
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, 127
AND	DWORD [esp], eax
POP	eax
ADD	eax, 128
PUSHD	eax
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
L10:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_set_cursor_pos:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
IMUL	eax, 80
PUSHD	eax
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
PUSHD	14
PUSHD	980
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, WORD [eax]
SHR	eax, 8
PUSHD	eax
PUSHD	981
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	15
PUSHD	980
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, WORD [eax]
PUSHD	eax
PUSHD	981
MOV	eax, V_outb
CALL	eax
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
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	981
MOV	eax, V_inb
CALL	eax
ADD	esp, 4
MOV	BYTE [ebp - (4)], al
PUSHD	15
PUSHD	980
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	981
MOV	eax, V_inb
CALL	eax
ADD	esp, 4
MOV	BYTE [ebp - (8)], al
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
SHL	eax, 8
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
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
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 757664
JAE	L13
PUSHD	3872
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	DWORD [eax], ebx
L14:
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L12
L13:
PUSHD	0
PUSHD	0
MOV	eax, V_set_cursor_pos
CALL	eax
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
L15:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 757504
JAE	L16
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 160
MOVZX	eax, WORD [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	DWORD [eax], ebx
L17:
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
JMP	L15
L16:
MOV	eax, 1
L18:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 757664
JAE	L19
PUSHD	3872
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	DWORD [eax], ebx
L20:
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
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
MOV	eax, ebp
SUB	eax, -20
MOVZX	eax, BYTE [eax]
CMP	eax, 0
JNE	L22
MOV	eax, V_terminal_color
MOVZX	eax, BYTE [eax]
MOV	BYTE [ebp - (-20)], al
L22:
L21:
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
CMP	eax, -1
MOV	eax, 0
SETE	al
PUSHD	eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
CMP	eax, -1
MOV	eax, 0
SETE	al
OR	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
CMP	eax, 80
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
CMP	eax, 25
MOV	eax, 0
SETAE	al
OR	DWORD [esp], eax
POP	eax
CMP	eax, 0
JE	L24
MOV	eax, V_get_cursor_pos
CALL	eax
MOV	DWORD [ebp - (8)], eax
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
MOV	ebx, 80
XOR	edx, edx
IDIV	ebx
MOV	eax, edx
MOV	DWORD [ebp - (-12)], eax
MOV	eax, ebp
SUB	eax, 8
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
SUB	DWORD [esp], eax
POP	eax
MOV	ebx, 80
XOR	edx, edx
IDIV	ebx
MOV	DWORD [ebp - (-16)], eax
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
CMP	eax, 10
JE	L26
CMP	eax, 13
JE	L27
CMP	eax, 9
JE	L28
JMP	L29
L26:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
MOV	DWORD [ebp - (16)], eax
JMP	L25
L27:
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (16)], eax
JMP	L25
L28:
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
ADD	eax, 8
PUSHD	eax
MOV	eax, 4294967288
AND	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
MOV	DWORD [ebp - (16)], eax
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
CMP	eax, 79
JBE	L31
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, 16
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (16)], eax
L31:
L30:
JMP	L25
L29:
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
IMUL	eax, 80
PUSHD	eax
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
SHL	eax, 1
ADD	eax, 753664
MOV	DWORD [ebp - (4)], eax
MOV	eax, ebp
SUB	eax, -20
MOVZX	eax, BYTE [eax]
SHL	eax, 8
PUSHD	eax
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
ADD	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	DWORD [eax], ebx
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
CMP	eax, 79
JAE	L33
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
MOV	DWORD [ebp - (16)], eax
JMP	L32
L33:
MOV	eax, 0
MOV	DWORD [ebp - (12)], eax
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (16)], eax
L32:
L25:
MOV	eax, ebp
SUB	eax, 16
MOV	eax, DWORD [eax]
CMP	eax, 25
JB	L35
MOV	eax, ebp
SUB	eax, 16
MOV	eax, DWORD [eax]
DEC	eax
MOV	DWORD [ebp - (16)], eax
MOV	eax, V_scroll
CALL	eax
L35:
L34:
MOV	eax, ebp
SUB	eax, 16
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 12
PUSHD	DWORD [eax]
MOV	eax, V_set_cursor_pos
CALL	eax
ADD	esp, 8
JMP	L23
L24:
MOV	eax, ebp
SUB	eax, -16
MOV	eax, DWORD [eax]
IMUL	eax, 80
PUSHD	eax
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
SHL	eax, 1
ADD	eax, 753664
MOV	DWORD [ebp - (4)], eax
MOV	eax, ebp
SUB	eax, -20
MOVZX	eax, BYTE [eax]
SHL	eax, 8
PUSHD	eax
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
ADD	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	DWORD [eax], ebx
L23:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_printf:
PUSH	ebp
MOV	ebp, esp
PUSHD	1
L36:
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
CMP	eax, 0
JE	L37
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
CMP	eax, 37
JNE	L39
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (-8)], eax
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
MOVZX	eax, BYTE [eax]
CMP	eax, 100
JE	L41
CMP	eax, 99
JE	L42
CMP	eax, 115
JE	L43
JMP	L44
L41:
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
MOV	eax, V_cstrud
CALL	eax
ADD	esp, 4
PUSHD	eax
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
JMP	L40
L42:
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, V_cstrub
CALL	eax
ADD	esp, 4
PUSHD	eax
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
JMP	L40
L43:
MOV	eax, ebp
SUB	eax, -8
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
SHL	eax, 2
ADD	DWORD [esp], eax
POP	eax
PUSHD	DWORD [eax]
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
JMP	L40
L44:
PUSHD	0
PUSHD	-1
PUSHD	-1
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
DEC	eax
PUSHD	eax
MOV	eax, V_putchar
CALL	eax
ADD	esp, 16
PUSHD	0
PUSHD	-1
PUSHD	-1
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
MOV	eax, V_putchar
CALL	eax
ADD	esp, 16
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
DEC	eax
MOV	DWORD [ebp - (4)], eax
L40:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L38
L39:
PUSHD	0
PUSHD	-1
PUSHD	-1
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
MOV	eax, V_putchar
CALL	eax
ADD	esp, 16
L38:
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (-8)], eax
JMP	L36
L37:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_sleep:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L45:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 3145727
JAE	L46
L47:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L45
L46:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_except_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L48
MOV	eax, V_printf
CALL	eax
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
PUSHD	L49
MOV	eax, V_printf
CALL	eax
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
PUSHD	L50
MOV	eax, V_printf
CALL	eax
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
PUSHD	L51
MOV	eax, V_printf
CALL	eax
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
PUSHD	L52
MOV	eax, V_printf
CALL	eax
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
PUSHD	L53
MOV	eax, V_printf
CALL	eax
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
PUSHD	L54
MOV	eax, V_printf
CALL	eax
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
PUSHD	L55
MOV	eax, V_printf
CALL	eax
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
L56:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 32
JAE	L57
PUSHD	V_except_default
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
L58:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L56
L57:
PUSHD	V_except_null_div
PUSHD	0
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_overflow
PUSHD	4
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_double_fault
PUSHD	8
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_ss_fault
PUSHD	12
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_gpf
PUSHD	13
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_page_fault
PUSHD	14
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
PUSHD	V_except_float
PUSHD	16
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_master_irq_default:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L59
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	32
PUSHD	32
MOV	eax, V_outb
CALL	eax
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
PUSHD	L60
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	32
PUSHD	160
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	32
PUSHD	32
MOV	eax, V_outb
CALL	eax
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
MOV	eax, V_inb
CALL	eax
ADD	esp, 4
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	L61
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	32
PUSHD	32
MOV	eax, V_outb
CALL	eax
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
L62:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 40
JAE	L63
PUSHD	V_master_irq_default
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
L64:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L62
L63:
MOV	eax, 40
MOV	DWORD [ebp - (4)], eax
L65:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 48
JAE	L66
PUSHD	V_slave_irq_default
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
L67:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L65
L66:
PUSHD	V_keyboard_handler
PUSHD	33
MOV	eax, V_install_interrupt_handler
CALL	eax
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
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
SHL	eax, 3
ADD	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, -12
PUSHD	DWORD [eax]
MOV	eax, 65535
AND	DWORD [esp], eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
POP	ebx
MOV	WORD [eax], bx
PUSHD	8
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 2
POP	ebx
MOV	WORD [eax], bx
PUSHD	142
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 5
POP	ebx
MOV	BYTE [eax], bl
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
SHR	eax, 16
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 6
POP	ebx
MOV	WORD [eax], bx
PUSHD	0
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
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
MOV	eax, V_inb
CALL	eax
ADD	esp, 4
MOV	BYTE [ebp - (4)], al
PUSHD	161
MOV	eax, V_inb
CALL	eax
ADD	esp, 4
MOV	BYTE [ebp - (8)], al
PUSHD	17
PUSHD	32
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	17
PUSHD	160
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
PUSHD	33
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, -12
PUSHD	DWORD [eax]
PUSHD	161
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	4
PUSHD	33
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	2
PUSHD	161
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	1
PUSHD	33
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
PUSHD	1
PUSHD	161
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	33
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	161
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_PIC_mask:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -8
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	33
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, -12
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	161
MOV	eax, V_outb
CALL	eax
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_generic_interrupt_handler:
PUSHAD
PUSH	ebp
MOV	ebp, esp
PUSHD	L68
MOV	eax, V_printf
CALL	eax
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
L69:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 256
JAE	L70
PUSHD	V_generic_interrupt_handler
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_install_interrupt_handler
CALL	eax
ADD	esp, 8
L71:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L69
L70:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_setup_interrupts:
PUSH	ebp
MOV	ebp, esp
MOV	eax, V_build_idt
CALL	eax
MOV	eax, V_install_generic_interrupt_handler
CALL	eax
MOV	eax, V_install_exception_interrupts
CALL	eax
MOV	eax, V_install_irq_interrupts
CALL	eax
PUSHD	40
PUSHD	32
MOV	eax, V_PIC_remap
CALL	eax
ADD	esp, 8
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_bitmap_get:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
SHR	eax, 3
PUSHD	eax
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
MOV	eax, 3
AND	DWORD [esp], eax
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
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
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
SHR	eax, 3
PUSHD	eax
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
MOV	eax, 3
AND	DWORD [esp], eax
POP	eax
MOV	cl, al
MOV	eax, 1
SHL	eax, cl
PUSHD	eax
MOV	eax, ebp
SUB	eax, -12
MOVZX	eax, BYTE [eax]
CMP	eax, 0
JE	L73
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
OR	DWORD [esp], eax
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
JMP	L72
L73:
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
NOT	eax
AND	DWORD [esp], eax
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L72:
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_palloc:
PUSH	ebp
MOV	ebp, esp
PUSHD	0
L74:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
CMP	eax, 1048576
JAE	L75
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
test	eax, eax
setz	al
and	eax, 0xff
CMP	eax, 0
JE	L78
PUSHD	1
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_bitmap_set
CALL	eax
ADD	esp, 8
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
SHL	eax, 12
JMP	@f
L78:
L77:
L76:
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (4)], eax
JMP	L74
L75:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_pfree:
PUSH	ebp
MOV	ebp, esp
MOV	eax, ebp
SUB	eax, -8
MOV	eax, DWORD [eax]
SHR	eax, 12
PUSHD	eax
PUSHD	0
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, V_bitmap_set
CALL	eax
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
PUSHD	L79
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
L80:
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
CMP	eax, 0
JBE	L81
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 20
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 16
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 8
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 12
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
PUSHD	DWORD [eax]
MOV	eax, ebp
SUB	eax, 4
MOV	eax, DWORD [eax]
ADD	eax, 4
PUSHD	DWORD [eax]
PUSHD	L82
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L80
L81:
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
L83:
MOV	eax, ebp
SUB	eax, 12
MOV	eax, DWORD [eax]
CMP	eax, 1310
JAE	L84
PUSHD	255
PUSHD	V_memory_bitmap
MOV	eax, ebp
SUB	eax, 12
MOV	eax, DWORD [eax]
ADD	DWORD [esp], eax
POP	eax
POP	ebx
MOV	BYTE [eax], bl
L85:
MOV	eax, ebp
SUB	eax, 12
MOV	eax, DWORD [eax]
INC	eax
MOV	DWORD [ebp - (12)], eax
JMP	L83
L84:
L86:
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
CMP	eax, 0
JBE	L87
MOV	eax, ebp
SUB	eax, 4
PUSHD	DWORD [eax]
MOV	eax, 24
ADD	DWORD [esp], eax
POP	eax
MOV	DWORD [ebp - (4)], eax
MOV	eax, ebp
SUB	eax, 8
MOV	eax, DWORD [eax]
DEC	eax
MOV	DWORD [ebp - (8)], eax
JMP	L86
L87:
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
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
MOV	eax, ebp
SUB	eax, -8
PUSHD	DWORD [eax]
PUSHD	L88
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
MOV	eax, ebp
SUB	eax, -12
MOV	eax, DWORD [eax]
CALL	eax
PUSHD	2
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
PUSHD	L89
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	15
MOV	eax, V_set_terminal_color
CALL	eax
ADD	esp, 4
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_main:
PUSH	ebp
MOV	ebp, esp
MOV	eax, V_init_vga
CALL	eax
PUSHD	L90
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	V_setup_interrupts
PUSHD	L91
MOV	eax, V_init_component
CALL	eax
ADD	esp, 8
PUSHD	V_setup_memory
PUSHD	L92
MOV	eax, V_init_component
CALL	eax
ADD	esp, 8
PUSHD	L93
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
MOV	eax, V_enum_memory_map
CALL	eax
PUSHD	42
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	1
PUSHD	42
MOV	eax, V_bitmap_set
CALL	eax
ADD	esp, 8
PUSHD	42
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	1
PUSHD	42
MOV	eax, V_bitmap_set
CALL	eax
ADD	esp, 8
PUSHD	42
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	0
PUSHD	42
MOV	eax, V_bitmap_set
CALL	eax
ADD	esp, 8
PUSHD	42
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
MOV	eax, ebp
SUB	eax, 16
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 12
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 8
MOVZX	eax, BYTE [eax]
PUSHD	eax
MOV	eax, ebp
SUB	eax, 4
MOVZX	eax, BYTE [eax]
PUSHD	eax
PUSHD	L94
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
MOV	eax, V_palloc
CALL	eax
PUSHD	eax
MOV	eax, V_palloc
CALL	eax
PUSHD	eax
PUSHD	L95
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	1
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	0
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	L96
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	0
MOV	eax, V_pfree
CALL	eax
ADD	esp, 4
PUSHD	4096
MOV	eax, V_pfree
CALL	eax
ADD	esp, 4
PUSHD	1
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	0
MOV	eax, V_bitmap_get
CALL	eax
ADD	esp, 4
PUSHD	eax
PUSHD	L97
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
PUSHD	255
PUSHD	253
MOV	eax, V_PIC_mask
CALL	eax
ADD	esp, 8
sti
PUSHD	L98
MOV	eax, V_printf
CALL	eax
ADD	esp, 4
L99:
hlt
JMP	L99
L100:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_buffd rb 9
V_buffb rb 3
V_terminal_color db 15
L48 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L49 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L50 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L51 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L52 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L53 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L54 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L55 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L59 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 109, 97, 115, 116, 101, 114, 41, 13, 10, 0
L60 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 32, 40, 115, 108, 97, 118, 101, 41, 32, 13, 10, 0
L61 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 37, 99, 13, 10, 0
align 16
V_idt rb 2048
V_idtr rb 6
L68 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
V_memory_bitmap rb 1310
L79 db 66, 97, 115, 101, 32, 65, 100, 100, 114, 101, 115, 115, 9, 9, 76, 101, 110, 103, 116, 104, 9, 9, 9, 84, 121, 112, 101, 9, 9, 65, 99, 112, 105, 32, 97, 116, 116, 114, 105, 98, 115, 13, 10, 0
L82 db 37, 100, 37, 100, 9, 37, 100, 37, 100, 9, 37, 100, 9, 37, 100, 13, 10, 0
L88 db 32, 43, 32, 37, 115, 0
L89 db 32, 91, 32, 79, 75, 32, 93, 13, 10, 0
L90 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L91 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 32, 0
L92 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 0
L93 db 84, 101, 115, 116, 105, 110, 103, 32, 109, 101, 109, 111, 114, 121, 58, 13, 10, 0
L94 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 63, 32, 48, 49, 32, 48, 49, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 32, 37, 99, 32, 37, 99, 13, 10, 0
L95 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 48, 48, 49, 48, 48, 48, 32, 48, 48, 48, 48, 48, 48, 48, 48, 58, 32, 37, 100, 32, 37, 100, 13, 10, 0
L96 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 49, 32, 48, 49, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L97 db 115, 104, 111, 117, 108, 100, 32, 112, 114, 105, 110, 116, 32, 48, 48, 32, 48, 48, 58, 32, 37, 99, 32, 37, 99, 13, 10, 0
L98 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
