use32
org 32768
JMP V_MAIN
KERNEL_ADDRESS = 07c00h+512+512
STACK_ADDRESS = 07c00h
IDT_ADDRESS = 00h
IDT_ENTRIES = 256
IDTR_ADDRESS = IDT_ADDRESS+IDT_ENTRIES*8
IDT_ERR_ENTRIES = 32
IRQ_NUMBER = 16
MASTER_IRQ_VECTOR_OFFSET = 020h
SLAVE_IRQ_VECTOR_OFFSET = 028h
VIDEO_MEMORY = 0B8000h
WHITE_ON_BLACK = 00fh
MAX_ROWS = 25
MAX_COLS = 80
REG_SCREEN_CTRL = 03D4h
REG_SCREEN_DATA = 03D5h
PIC1_COMMAND = 020h
PIC1_DATA = 021h
PIC2_COMMAND = 0A0h
PIC2_DATA = 0A1h
ICW1_INIT = 010h
ICW1_ICW4 = 001h
PIC_EOI = 020h
ICW4_8086 = 001h
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
V_INIT_VGA:
PUSH ebp
MOV ebp, esp
CALL V_CLEAR_SCREEN
ADD esp, 0
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
MOV eax, MAX_COLS
PUSHD eax
MOV eax, DWORD [ebp + 8]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, REG_SCREEN_CTRL
PUSHD eax
MOV eax, 00Eh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, REG_SCREEN_DATA
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
MOV eax, REG_SCREEN_CTRL
PUSHD eax
MOV eax, 00Fh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, REG_SCREEN_DATA
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
MOV eax, REG_SCREEN_CTRL
PUSHD eax
MOV eax, 00Eh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, REG_SCREEN_DATA
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, REG_SCREEN_CTRL
PUSHD eax
MOV eax, 00Fh
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, REG_SCREEN_DATA
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
	mov ax, 0x0f * 256 + ' '
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
	mov ax, 0x0F20
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
TEST eax, eax
JZ L5
CALL V_GET_CURSOR_POS
ADD esp, 0
MOV DWORD [ebp - 4], eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, MAX_COLS
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
MOV eax, MAX_COLS
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
MOV eax, MAX_COLS
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
MOV eax, VIDEO_MEMORY
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
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L10
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
JMP L9
L10:
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L9
L9:
JMP L6
L6:
MOV eax, DWORD [ebp - 16]
PUSHD eax
MOV eax, MAX_ROWS
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETGE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L12
MOV eax, 1
SUB DWORD [ebp - 16], eax
CALL V_SCROLL
ADD esp, 0
JMP L11
L12:
L11:
MOV eax, DWORD [ebp - 12]
PUSHD eax
MOV eax, DWORD [ebp - 16]
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
JMP L4
L5:
MOV eax, MAX_COLS
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
MOV eax, VIDEO_MEMORY
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
L13:
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
JZ L14
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
JMP L13
L14:
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
L15:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0FFFFFh
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L16
INC DWORD [ebp - 4]
JMP L15
L16:
RET_SLEEP:
MOV esp, ebp
POP ebp
RET
V_MAIN:
PUSH ebp
MOV ebp, esp
CALL V_INIT_VGA
ADD esp, 0
MOV eax, L17
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L18
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 01fh
PUSHD eax
CALL V_SET_TERMINAL_COLOR
ADD esp, 4
MOV eax, 1
PUSHD eax
CALL V_SET_BLINKING
ADD esp, 4
MOV eax, L19
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 0
PUSHD eax
CALL V_SET_BLINKING
ADD esp, 4
MOV eax, L20
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L21
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L22:
hlt
JMP L22
L23:
RET_MAIN:
MOV esp, ebp
POP ebp
RET
V_KEYBOARD_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L24
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 060h
PUSHD eax
CALL V_INB
ADD esp, 4
MOV eax, PIC1_COMMAND
PUSHD eax
MOV eax, PIC_EOI
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
V_TERMINAL_COLOR db 0
L17 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L18 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L19 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 32, 98, 108, 105, 110, 107, 13, 10, 0
L20 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 110, 39, 116, 13, 10, 0
L21 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L24 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 0
