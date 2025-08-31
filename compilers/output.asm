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
V_main:
PUSH	ebp
MOV	ebp, esp
CALL	V_init_vga
PUSHD	L51
CALL	V_printf
ADD	esp, 4
PUSHD	31
CALL	V_set_terminal_color
ADD	esp, 4
PUSHD	1
CALL	V_set_blinking
ADD	esp, 4
PUSHD	L52
CALL	V_printf
ADD	esp, 4
PUSHD	0
CALL	V_set_blinking
ADD	esp, 4
PUSHD	L53
CALL	V_printf
ADD	esp, 4
PUSHD	L54
CALL	V_printf
ADD	esp, 4
PUSHD	0
PUSHD	1
PUSHD	1
PUSHD	L55
CALL	V_putchar
ADD	esp, 16
L56:
hlt
JMP	L56
L57:
MOV	eax, 0
@@:
MOV	esp, ebp
POP	ebp
RET	0
V_buffd rb 9
V_buffb rb 3
V_terminal_color db 15
L51 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L52 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 32, 98, 108, 105, 110, 107, 13, 10, 0
L53 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 110, 39, 116, 13, 10, 0
L54 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L55 db 120, 0
