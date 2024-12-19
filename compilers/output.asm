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
; Variable store here
@@:
MOV esp, ebp
POP ebp
RET
V_SET_BLINKING:
PUSH ebp
MOV ebp, esp
PUSHD eax
MOV eax, 0
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
CMP eax, 0
JNE L8
MOVZX eax, BYTE[V_TERMINAL_COLOR]
PUSHD eax
MOV eax, 127
AND eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_SET_TERMINAL_COLOR
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
MOV eax, 80
PUSHD eax
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
ADD eax, DWORD [esp]
ADD esp, 4
; Variable store here
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_OUTB
MOV eax, 981
PUSHD eax
PUSHD eax
MOV eax, 8
MOV cl, al
SHR DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
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
MOV eax, 981
PUSHD eax
CALL V_INB
; Variable store here
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_OUTB
MOV eax, 981
PUSHD eax
CALL V_INB
; Variable store here
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
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
SUB esp, 2
SUB esp, 4
SUB esp, 4
SUB esp, 4
PUSHD eax
MOV eax, 0
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
CMP eax, 0
JNE L10
MOVZX eax, BYTE[V_TERMINAL_COLOR]
; Variable store here
JMP L9
L10:
L9:
PUSHD eax
MOV eax, -1
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
PUSHD eax
PUSHD eax
MOV eax, -1
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
PUSHD eax
MOV eax, 80
CMP eax, DWORD [esp]
MOV eax, 0
SETAE al
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
PUSHD eax
MOV eax, 25
CMP eax, DWORD [esp]
MOV eax, 0
SETAE al
OR eax, DWORD [esp]
ADD esp, 4
CMP eax, 0
JNE L12
CALL V_GET_CURSOR_POS
; Variable store here
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV eax, edx
; Variable store here
PUSHD eax
SUB eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 80
MOV ebx, DWORD [esp]
ADD esp, 4
XCHG eax, ebx
XOR edx, edx
IDIV ebx
; Variable store here
; Dereference here
PUSHD eax
MOV eax, 13
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
CMP eax, 0
JNE L14
MOV eax, 0
; Variable store here
; Variable store here
JMP L13
L14:
; Dereference here
PUSHD eax
MOV eax, 10
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
CMP eax, 0
JNE L15
; Variable store here
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
; Variable store here
JMP L13
L15:
; Dereference here
PUSHD eax
MOV eax, 9
CMP eax, DWORD [esp]
MOV eax, 0
SETE al
CMP eax, 0
JNE L16
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
; Variable store here
PUSHD eax
MOV eax, 8
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
AND eax, DWORD [esp]
ADD esp, 4
; Variable store here
PUSHD eax
MOV eax, 79
CMP eax, DWORD [esp]
MOV eax, 0
SETA al
CMP eax, 0
JNE L18
MOV eax, 0
; Variable store here
INC eax
; Variable store here
JMP L17
L18:
L17:
JMP L13
L16:
MOV eax, 80
PUSHD eax
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
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
; Variable store here
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
; Dereference here
ADD eax, DWORD [esp]
ADD esp, 4
; Variable dereference store here
PUSHD eax
MOV eax, 79
CMP eax, DWORD [esp]
MOV eax, 0
SETB al
CMP eax, 0
JNE L20
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
; Variable store here
; Variable store here
JMP L19
L20:
MOV eax, 0
; Variable store here
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
; Variable store here
JMP L19
L19:
JMP L13
L13:
PUSHD eax
MOV eax, 25
CMP eax, DWORD [esp]
MOV eax, 0
SETAE al
CMP eax, 0
JNE L22
DEC eax
; Variable store here
CALL V_SCROLL
JMP L21
L22:
L21:
PUSHD eax
PUSHD eax
CALL V_SET_CURSOR_POS
JMP L11
L12:
MOV eax, 80
PUSHD eax
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
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
; Variable store here
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
; Dereference here
ADD eax, DWORD [esp]
ADD esp, 4
; Variable dereference store here
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
; Dereference here
PUSHD eax
MOV eax, 0
CMP eax, DWORD [esp]
MOV eax, 0
SETNE al
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
; Variable store here
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
PUSHD eax
MOV eax, 5242879
CMP eax, DWORD [esp]
MOV eax, 0
SETB al
CMP eax, 0
JE L26
INC eax
; Variable store here
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
