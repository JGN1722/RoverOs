use32
org 32768
JMP V_MAIN
KERNEL_ADDRESS = 0x7e00+512
STACK_ADDRESS = 0x520
IDT_ADDRESS = 0x1
IDT_ENTRIES = 50
IDTR_ADDRESS = IDT_ADDRESS+IDT_ENTRIES*8
VIDEO_MEMORY = 0xB8000
WHITE_ON_BLACK = 0x0f
MAX_ROWS = 25
MAX_COLS = 80
REG_SCREEN_CTRL = 0x3D4
REG_SCREEN_DATA = 0x3D5
PIC1_COMMAND = 0x20
PIC1_DATA = 0x21
PIC2_COMMAND = 0xA0
PIC2_DATA = 0xA1
ICW1_INIT = 0x10
ICW1_ICW4 = 0x01
PIC_EOI = 0x20
PIT_CHANNEL_0 = 0x40
PIT_COMMAND = 0x43
PIT_FREQ = 1193180
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
MOV eax, 0x0E
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
MOV eax, 0x0F
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
MOV eax, 0x0E
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
MOV eax, 0x0F
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
SUB esp, 12
MOV eax, VIDEO_MEMORY
MOV DWORD [ebp - 4], eax
MOV eax, MAX_COLS
PUSHD eax
MOV eax, MAX_ROWS
IMUL DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, 0
MOV DWORD [ebp - 12], eax
L0:
MOV eax, DWORD [ebp - 12]
PUSHD eax
MOV eax, DWORD [ebp - 8]
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L1
MOV eax, WHITE_ON_BLACK
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 32
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 4]
MOV WORD [ebx], ax
MOV eax, 2
ADD DWORD [ebp - 4], eax
INC DWORD [ebp - 12]
JMP L0
L1:
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
PUSHD eax
MOV eax, DWORD [ebp + 8]
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
JZ L3
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
MOV DWORD [ebp + 12], eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, DWORD [ebp + 12]
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
MOV DWORD [ebp + 8], eax
MOV ebx, DWORD [ebp + 16]
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
JZ L5
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 8]
MOV DWORD [ebp - 16], eax
JMP L4
L5:
MOV ebx, DWORD [ebp + 16]
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
JZ L6
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L4
L6:
MOV eax, MAX_COLS
PUSHD eax
MOV eax, DWORD [ebp + 8]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
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
MOV eax, WHITE_ON_BLACK
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV ebx, DWORD [ebp + 16]
MOV eax, 0
MOV al, BYTE [ebx]
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 8]
MOV WORD [ebx], ax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 79
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L8
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 8]
MOV DWORD [ebp - 16], eax
JMP L7
L8:
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L7
L7:
JMP L4
L4:
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
JZ L10
MOV eax, 1
SUB DWORD [ebp - 16], eax
CALL V_SCROLL
ADD esp, 0
JMP L9
L10:
L9:
MOV eax, DWORD [ebp - 12]
PUSHD eax
MOV eax, DWORD [ebp - 16]
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
JMP L2
L3:
MOV eax, MAX_COLS
PUSHD eax
MOV eax, DWORD [ebp + 8]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
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
MOV eax, WHITE_ON_BLACK
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
MOV eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV ebx, DWORD [ebp + 16]
MOV eax, 0
MOV al, BYTE [ebx]
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 8]
MOV WORD [ebx], ax
JMP L2
L2:
RET_PUTCHAR:
MOV esp, ebp
POP ebp
RET
V_PRINTF:
PUSH ebp
MOV ebp, esp
L11:
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
JZ L12
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
CALL V_PUTCHAR
ADD esp, 12
INC DWORD [ebp + 8]
JMP L11
L12:
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
L13:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0xFFFFF
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L14
INC DWORD [ebp - 4]
JMP L13
L14:
RET_SLEEP:
MOV esp, ebp
POP ebp
RET
V_MAIN:
PUSH ebp
MOV ebp, esp
SUB esp, 4
CALL V_CLEAR_SCREEN
ADD esp, 0
MOV eax, 0
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_SET_CURSOR_POS
ADD esp, 8
MOV eax, L15
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L16
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_BUILD_IDT
ADD esp, 0
MOV eax, 0
MOV DWORD [ebp - 4], eax
L17:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, IDT_ENTRIES
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L18
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_GENERIC_INTERRUPT_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L17
L18:
sti
L19:
JMP L19
L20:
RET_MAIN:
MOV esp, ebp
POP ebp
RET
V_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
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
JZ L22
MOV eax, L23
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L21
L22:
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 1
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L24
MOV eax, L25
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L21
L24:
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 14
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L26
MOV eax, L27
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L21
L26:
MOV eax, L28
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L21
L21:
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 32
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETGE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L30
MOV eax, 0x20
PUSHD eax
MOV eax, 0x20
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, DWORD [ebp + 8]
PUSHD eax
MOV eax, 40
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETGE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L32
MOV eax, 0xA0
PUSHD eax
MOV eax, 0x20
PUSHD eax
CALL V_OUTB
ADD esp, 8
JMP L31
L32:
L31:
JMP L29
L30:
L29:

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_GENERIC_INTERRUPT_HANDLER:
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
	
RET_INSTALL_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_BUILD_IDT:
PUSH ebp
MOV ebp, esp

	;build idt
	mov ecx, IDT_ENTRIES * 2 / 4
	mov eax, 0
	mov edi, IDT_ADDRESS
	rep stosd
	
	;build idtr
	mov WORD [IDTR_ADDRESS], (IDT_ENTRIES*8)-1
	mov DWORD [IDTR_ADDRESS + 2], IDT_ADDRESS
	
	lidt [IDTR_ADDRESS]  ; Load the IDT register with the IDTR structure (points to our custom IDT)
	
RET_BUILD_IDT:
MOV esp, ebp
POP ebp
RET
L15 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L16 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 73, 68, 84, 46, 46, 46, 13, 10, 0
L23 db 116, 105, 109, 101, 114, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 13, 10, 0
L25 db 107, 101, 121, 98, 111, 97, 114, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 13, 10, 0
L27 db 112, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L28 db 117, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 13, 10, 0
