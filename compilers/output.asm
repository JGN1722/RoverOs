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
MOV eax, 31
PUSHD eax
CALL V_SET_TERMINAL_COLOR
MOV eax, 1
PUSHD eax
CALL V_SET_BLINKING
MOV eax, L1
PUSHD eax
CALL V_PRINTF
MOV eax, 0
PUSHD eax
CALL V_SET_BLINKING
MOV eax, L2
PUSHD eax
CALL V_PRINTF
MOV eax, L3
PUSHD eax
CALL V_PRINTF
MOV eax, L4
PUSHD eax
MOV eax, 1
PUSHD eax
MOV eax, 1
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_PUTCHAR
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
V_INIT_VGA:
PUSH ebp
MOV ebp, esp
CALL V_CLEAR_SCREEN
MOV eax, 15
PUSHD eax
CALL V_SET_TERMINAL_COLOR
MOV eax, 0
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_SET_CURSOR_POS
@@:
MOV esp, ebp
POP ebp
RET
V_SET_TERMINAL_COLOR:
PUSH ebp
MOV ebp, esp
; Assignement here
@@:
MOV esp, ebp
POP ebp
RET
V_SET_BLINKING:
PUSH ebp
MOV ebp, esp
; Relation here
CMP eax, 0
JNE L8
; BinaryOp here
PUSHD eax
CALL V_SET_TERMINAL_COLOR
JMP L7
L8:
; BinaryOp here
PUSHD eax
CALL V_SET_TERMINAL_COLOR
JMP L7
L7:
@@:
MOV esp, ebp
POP ebp
RET
V_SET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 1
; Assignement here
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_OUTB
MOV eax, 981
PUSHD eax
; BinaryOp here
PUSHD eax
CALL V_OUTB
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_OUTB
MOV eax, 981
PUSHD eax
PUSHD eax
CALL V_OUTB
@@:
MOV esp, ebp
POP ebp
RET
V_GET_CURSOR_POS:
PUSH ebp
MOV ebp, esp
SUB esp, 1
SUB esp, 1
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_OUTB
; Assignement here
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_OUTB
; Assignement here
; BinaryOp here
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
SUB esp, 2
SUB esp, 4
SUB esp, 4
SUB esp, 4
; Relation here
CMP eax, 0
JNE L10
; Assignement here
JMP L9
L10:
L9:
; BinaryOp here
CMP eax, 0
JNE L12
; Assignement here
; Assignement here
; Assignement here
; Relation here
CMP eax, 0
JNE L14
; Assignement here
; Assignement here
JMP L13
L14:
; Relation here
CMP eax, 0
JNE L15
; Assignement here
; Assignement here
JMP L13
L15:
; Relation here
CMP eax, 0
JNE L16
; BinaryOp here
; Assignement here
; Relation here
CMP eax, 0
JNE L18
; Assignement here
INC eax
; Store to variable here
JMP L17
L18:
L17:
JMP L13
L16:
; Assignement here
; Assignement here
; Relation here
CMP eax, 0
JNE L20
; Assignement here
; Assignement here
JMP L19
L20:
; Assignement here
; Assignement here
JMP L19
L19:
JMP L13
L13:
; Relation here
CMP eax, 0
JNE L22
DEC eax
; Store to variable here
CALL V_SCROLL
JMP L21
L22:
L21:
PUSHD eax
PUSHD eax
CALL V_SET_CURSOR_POS
JMP L11
L12:
; Assignement here
; Assignement here
JMP L11
L11:
@@:
MOV esp, ebp
POP ebp
RET
V_PRINTF:
PUSH ebp
MOV ebp, esp
L23:
; Relation here
CMP eax, 0
JE L24
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_PUTCHAR
INC eax
; Store to variable here
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
; Relation here
CMP eax, 0
JE L26
INC eax
; Store to variable here
JMP L25
L26:
@@:
MOV esp, ebp
POP ebp
RET
V_TERMINAL_COLOR rb 1
L0 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L1 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 32, 98, 108, 105, 110, 107, 13, 10, 0
L2 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 110, 39, 116, 13, 10, 0
L3 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L4 db 120, 0
