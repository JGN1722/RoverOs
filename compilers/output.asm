use32
org 32768
JMP V_MAIN
KERNEL_ADDRESS = 07c00h+512+512
STACK_ADDRESS = 07c00h-1
IDT_ADDRESS = 00h
IDT_ENTRIES = 256
IDTR_ADDRESS = IDT_ADDRESS+IDT_ENTRIES*8
IDTR_SIZE = 6
MEM_MAP_ADDRESS = IDTR_ADDRESS+IDTR_SIZE
MEM_MAP_ENTRIES_START = MEM_MAP_ADDRESS+4
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
	
RET_CSTRUD:
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
	
RET_CSTRUB:
MOV esp, ebp
POP ebp
RET
V_INIT_VGA:
PUSH ebp
MOV ebp, esp
CALL V_CLEAR_SCREEN
MOV eax, WHITE_ON_BLACK
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
	mov ax, WHITE_ON_BLACK * 256 + ' '
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
	mov ax, WHITE_ON_BLACK * 256 + ' '
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
PUSHD eax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, MAX_COLS
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, MAX_ROWS
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
OR eax, DWORD [esp]
ADD esp, 4
TEST eax, eax
JZ L5
CALL V_GET_CURSOR_POS
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
MOV ebx, DWORD [ebp + 20]
MOV eax, 0
MOV al, BYTE [ebx]
PUSHD eax
MOV eax, 9
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L9
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 8
PUSHD eax
MOV eax, 1
SUB eax, DWORD [esp]
ADD esp, 4
NEG eax
NOT eax
AND eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 79
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L11
MOV eax, 0
MOV DWORD [ebp - 12], eax
INC DWORD [ebp - 16]
JMP L10
L11:
L10:
JMP L6
L9:
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
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L13
MOV eax, DWORD [ebp + 16]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
MOV DWORD [ebp - 16], eax
JMP L12
L13:
MOV eax, 0
MOV DWORD [ebp - 12], eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 16], eax
JMP L12
L12:
JMP L6
L6:
MOV eax, DWORD [ebp - 16]
PUSHD eax
MOV eax, MAX_ROWS
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETAE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L15
DEC DWORD [ebp - 16]
CALL V_SCROLL
JMP L14
L15:
L14:
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
L16:
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
JZ L17
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
JMP L16
L17:
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
L18:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 04FFFFFh
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L19
INC DWORD [ebp - 4]
JMP L18
L19:
RET_SLEEP:
MOV esp, ebp
POP ebp
RET
V_ENUM_MEMORY_MAP:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, MEM_MAP_ADDRESS
MOV DWORD [ebp - 8], eax
MOV ebx, DWORD [ebp - 8]
MOV eax, 0
MOV eax, DWORD [ebx]
MOV DWORD [ebp - 4], eax
MOV eax, 4
ADD DWORD [ebp - 8], eax
MOV eax, L20
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L21:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L22
MOV eax, DWORD [ebp - 8]
ADD eax, 4
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 0
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L23
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 12
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 8
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L24
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, DWORD [ebp - 8]
ADD eax, 16
MOV eax, DWORD [eax]
PUSHD eax
CALL V_CSTRUD
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L25
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 24
ADD DWORD [ebp - 8], eax
DEC DWORD [ebp - 4]
JMP L21
L22:
RET_ENUM_MEMORY_MAP:
MOV esp, ebp
POP ebp
RET
V_FILL_BITMAP:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, MEM_MAP_ADDRESS
MOV DWORD [ebp - 8], eax
MOV ebx, DWORD [ebp - 8]
MOV eax, 0
MOV eax, DWORD [ebx]
MOV DWORD [ebp - 4], eax
MOV eax, 4
ADD DWORD [ebp - 8], eax
L26:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, 0
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETA al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L27
MOV eax, DWORD [ebp - 8]
ADD eax, 16
MOV eax, DWORD [eax]
PUSHD eax
MOV eax, 1
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETE al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L29
MOV eax, L30
PUSHD eax
CALL V_PRINTF
ADD esp, 4
JMP L28
L29:
L28:
MOV eax, 24
ADD DWORD [ebp - 8], eax
DEC DWORD [ebp - 4]
JMP L26
L27:
RET_FILL_BITMAP:
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
	
RET_BUILD_IDT:
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
V_PIC_REMAP:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, PIC1_DATA
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 4], eax
MOV eax, PIC2_DATA
PUSHD eax
CALL V_INB
ADD esp, 4
MOV DWORD [ebp - 8], eax
MOV eax, PIC1_COMMAND
PUSHD eax
MOV eax, ICW1_INIT
PUSHD eax
MOV eax, ICW1_ICW4
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_COMMAND
PUSHD eax
MOV eax, ICW1_INIT
PUSHD eax
MOV eax, ICW1_ICW4
OR eax, DWORD [esp]
ADD esp, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC1_DATA
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_DATA
PUSHD eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC1_DATA
PUSHD eax
MOV eax, 4
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_DATA
PUSHD eax
MOV eax, 2
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC1_DATA
PUSHD eax
MOV eax, ICW4_8086
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_DATA
PUSHD eax
MOV eax, ICW4_8086
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC1_DATA
PUSHD eax
MOV eax, DWORD [ebp - 4]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_DATA
PUSHD eax
MOV eax, DWORD [ebp - 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
RET_PIC_REMAP:
MOV esp, ebp
POP ebp
RET
V_PIC_MASK:
PUSH ebp
MOV ebp, esp
MOV eax, PIC1_DATA
PUSHD eax
MOV eax, DWORD [ebp + 12]
PUSHD eax
CALL V_OUTB
ADD esp, 8
MOV eax, PIC2_DATA
PUSHD eax
MOV eax, DWORD [ebp + 8]
PUSHD eax
CALL V_OUTB
ADD esp, 8
RET_PIC_MASK:
MOV esp, ebp
POP ebp
RET
V_GENERIC_INTERRUPT_HANDLER:
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
	
RET_GENERIC_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_INSTALL_GENERIC_INTERRUPT_HANDLER:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [ebp - 4], eax
L32:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, IDT_ENTRIES
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L33
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_GENERIC_INTERRUPT_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L32
L33:
RET_INSTALL_GENERIC_INTERRUPT_HANDLER:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DEFAULT:
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
	
RET_EXCEPT_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_NULL_DIV:
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
	
RET_EXCEPT_NULL_DIV:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_OVERFLOW:
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
	
RET_EXCEPT_OVERFLOW:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_DOUBLE_FAULT:
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
	
RET_EXCEPT_DOUBLE_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_SS_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L38
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_SS_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_GPF:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L39
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_GPF:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_PAGE_FAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L40
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_PAGE_FAULT:
MOV esp, ebp
POP ebp
RET
V_EXCEPT_FLOAT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L41
PUSHD eax
CALL V_PRINTF
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
RET_EXCEPT_FLOAT:
MOV esp, ebp
POP ebp
RET
V_INSTALL_EXCEPTION_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, 0
MOV DWORD [ebp - 4], eax
L42:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, IDT_ERR_ENTRIES
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L43
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_EXCEPT_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L42
L43:
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
RET_INSTALL_EXCEPTION_INTERRUPTS:
MOV esp, ebp
POP ebp
RET
V_MASTER_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L44
PUSHD eax
CALL V_PRINTF
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
	
RET_MASTER_IRQ_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_SLAVE_IRQ_DEFAULT:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L45
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, PIC2_COMMAND
PUSHD eax
MOV eax, PIC_EOI
PUSHD eax
CALL V_OUTB
ADD esp, 8
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
	
RET_SLAVE_IRQ_DEFAULT:
MOV esp, ebp
POP ebp
RET
V_INSTALL_IRQ_INTERRUPTS:
PUSH ebp
MOV ebp, esp
SUB esp, 4
MOV eax, MASTER_IRQ_VECTOR_OFFSET
MOV DWORD [ebp - 4], eax
L46:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, MASTER_IRQ_VECTOR_OFFSET
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L47
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_MASTER_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L46
L47:
MOV eax, SLAVE_IRQ_VECTOR_OFFSET
MOV DWORD [ebp - 4], eax
L48:
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, SLAVE_IRQ_VECTOR_OFFSET
PUSHD eax
MOV eax, 8
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETL al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L49
MOV eax, DWORD [ebp - 4]
PUSHD eax
MOV eax, V_SLAVE_IRQ_DEFAULT
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
INC DWORD [ebp - 4]
JMP L48
L49:
MOV eax, MASTER_IRQ_VECTOR_OFFSET
PUSHD eax
MOV eax, 1
ADD eax, DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, V_KEYBOARD_HANDLER
PUSHD eax
CALL V_INSTALL_INTERRUPT_HANDLER
ADD esp, 8
RET_INSTALL_IRQ_INTERRUPTS:
MOV esp, ebp
POP ebp
RET
V_MAIN:
PUSH ebp
MOV ebp, esp
CALL V_INIT_VGA
MOV eax, L50
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L51
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_ENUM_MEMORY_MAP
CALL V_FILL_BITMAP
MOV eax, L52
PUSHD eax
CALL V_PRINTF
ADD esp, 4
CALL V_BUILD_IDT
CALL V_INSTALL_GENERIC_INTERRUPT_HANDLER
CALL V_INSTALL_EXCEPTION_INTERRUPTS
CALL V_INSTALL_IRQ_INTERRUPTS
MOV eax, MASTER_IRQ_VECTOR_OFFSET
PUSHD eax
MOV eax, SLAVE_IRQ_VECTOR_OFFSET
PUSHD eax
CALL V_PIC_REMAP
ADD esp, 8
MOV eax, 0fdh
PUSHD eax
MOV eax, 0ffh
PUSHD eax
CALL V_PIC_MASK
ADD esp, 8
sti
MOV eax, L53
PUSHD eax
CALL V_PRINTF
ADD esp, 4
L54:
hlt
JMP L54
L55:
RET_MAIN:
MOV esp, ebp
POP ebp
RET
V_KEYBOARD_HANDLER:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L56
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L57
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, 060h
PUSHD eax
CALL V_INB
ADD esp, 4
PUSHD eax
CALL V_CSTRUB
ADD esp, 4
PUSHD eax
CALL V_PRINTF
ADD esp, 4
MOV eax, L58
PUSHD eax
CALL V_PRINTF
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
V_TERMINAL_COLOR dd 0
L20 db 98, 97, 115, 101, 9, 9, 9, 108, 101, 110, 9, 9, 9, 116, 121, 112, 101, 13, 10, 0
L23 db 9, 0
L24 db 9, 0
L25 db 13, 10, 0
L30 db 117, 115, 97, 98, 108, 101, 32, 109, 101, 109, 111, 114, 121, 32, 114, 101, 103, 105, 111, 110, 32, 102, 111, 117, 110, 100, 0
L31 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L34 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L35 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L36 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L37 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L38 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L39 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L40 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L41 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L44 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L45 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L50 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L51 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 109, 101, 109, 111, 114, 121, 46, 46, 46, 13, 10, 0
L52 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L53 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L56 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 32, 0
L57 db 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 0
L58 db 13, 10, 0
