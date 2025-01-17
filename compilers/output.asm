use32
org 32768
JMP V_main
V_inb:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in al, dx
@@:
MOV esp, ebp
POP ebp
RET
V_inw:
PUSH ebp
MOV ebp, esp
XOR eax, eax
MOV edx, DWORD [ebp + 8]
in ax, dx
@@:
MOV esp, ebp
POP ebp
RET
V_ind:
PUSH ebp
MOV ebp, esp
MOV edx, DWORD [ebp + 8]
in eax, dx
@@:
MOV esp, ebp
POP ebp
RET
V_outb:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, al
@@:
MOV esp, ebp
POP ebp
RET
V_outw:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, ax
@@:
MOV esp, ebp
POP ebp
RET
V_outd:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp + 8]
MOV edx, DWORD [ebp + 12]
out dx, eax
@@:
MOV esp, ebp
POP ebp
RET
V_cstrud:
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
	and eax, 0fh
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 0ah	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,0ah
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
MOV esp, ebp
POP ebp
RET
V_cstrudx:
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
	and eax, 0fh
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 0ah	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,0ah
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
MOV esp, ebp
POP ebp
RET
V_cstrub:
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
	and eax, 0fh
	pop ecx		;ecx has been modified and won't be again, so restore it
	
	cmp al, 0ah	;convert to character
	jae .letter
	add al, '0'
	jmp .poke
	.letter:
	sub al,0ah
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
MOV esp, ebp
POP ebp
RET
V_init_vga:
PUSH ebp
MOV ebp, esp
CALL V_clear_screen
MOV eax, 15
PUSHD eax
CALL V_set_terminal_color
ADD esp, 4
MOV eax, 0
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_set_cursor_pos
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_set_terminal_color:
PUSH ebp
MOV ebp, esp
MOVZX eax, BYTE [ebp - (-8)]
MOV BYTE [V_terminal_color], al
@@:
MOV esp, ebp
POP ebp
RET
V_set_blinking:
PUSH ebp
MOV ebp, esp
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L1
MOVZX eax, BYTE[V_terminal_color]
PUSHD eax
MOV eax, 127
AND DWORD [esp], eax
POP eax
PUSHD eax
CALL V_set_terminal_color
ADD esp, 4
JMP L0
L1:
MOVZX eax, BYTE[V_terminal_color]
PUSHD eax
MOV eax, 127
AND DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 128
ADD DWORD [esp], eax
POP eax
PUSHD eax
CALL V_set_terminal_color
ADD esp, 4
L0:
@@:
MOV esp, ebp
POP ebp
RET
V_set_cursor_pos:
PUSH ebp
MOV ebp, esp
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-8)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 981
PUSHD eax
MOVZX eax, WORD [ebp - (4)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHR DWORD [esp], cl
POP eax
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 981
PUSHD eax
MOVZX eax, WORD [ebp - (4)]
PUSHD eax
CALL V_outb
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_get_cursor_pos:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
MOV eax, 980
PUSHD eax
MOV eax, 14
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 981
PUSHD eax
CALL V_inb
ADD esp, 4
MOV BYTE [ebp - (4)], al
MOV eax, 980
PUSHD eax
MOV eax, 15
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 981
PUSHD eax
CALL V_inb
ADD esp, 4
MOV BYTE [ebp - (8)], al
MOVZX eax, BYTE [ebp - (4)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
POP eax
PUSHD eax
MOVZX eax, BYTE [ebp - (8)]
ADD DWORD [esp], eax
POP eax
JMP @f
@@:
MOV esp, ebp
POP ebp
RET
V_clear_screen:
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
V_scroll:
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
V_putchar:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
SUB esp, 4
SUB esp, 4
SUB esp, 4
SUB esp, 4
SUB esp, 4
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L3
MOVZX eax, BYTE[V_terminal_color]
MOV BYTE [ebp - (-8)], al
L3:
L2:
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, -1
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, -1
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
OR DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 80
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
OR DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 25
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
OR DWORD [esp], eax
POP eax
CMP eax, 0
JE L5
CALL V_get_cursor_pos
MOV DWORD [ebp - (8)], eax
MOV eax, DWORD [ebp - (8)]
PUSHD eax
MOV eax, 80
POP ebx
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV eax, edx
MOV DWORD [ebp - (-16)], eax
MOV eax, DWORD [ebp - (8)]
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
SUB DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 80
POP ebx
XCHG eax, ebx
XOR edx, edx
IDIV ebx
MOV DWORD [ebp - (-12)], eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 13
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L7
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L6
L7:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 10
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L8
MOV eax, DWORD [ebp - (-16)]
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
MOV DWORD [ebp - (16)], eax
JMP L6
L8:
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 9
CMP DWORD [esp], eax
MOV eax, 0
SETE al
ADD esp, 4
CMP eax, 0
JE L9
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 8
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 8
PUSHD eax
MOV eax, 1
SUB DWORD [esp], eax
POP eax
NOT eax
AND DWORD [esp], eax
POP eax
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 79
CMP DWORD [esp], eax
MOV eax, 0
SETA al
ADD esp, 4
CMP eax, 0
JE L11
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (16)]
INC eax
MOV DWORD [ebp - (16)], eax
L11:
L10:
JMP L6
L9:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
POP eax
PUSHD eax
MOV eax, 753664
ADD DWORD [esp], eax
POP eax
MOV DWORD [ebp - (4)], eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (4)]
MOV ebx, DWORD [esp]
MOV WORD [eax], bx
ADD esp, 4
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 79
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L13
MOV eax, DWORD [ebp - (-16)]
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
MOV DWORD [ebp - (16)], eax
JMP L12
L13:
MOV eax, 0
MOV DWORD [ebp - (12)], eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
MOV DWORD [ebp - (16)], eax
L12:
L6:
MOV eax, DWORD [ebp - (16)]
PUSHD eax
MOV eax, 25
CMP DWORD [esp], eax
MOV eax, 0
SETAE al
ADD esp, 4
CMP eax, 0
JE L15
MOV eax, DWORD [ebp - (16)]
DEC eax
MOV DWORD [ebp - (16)], eax
CALL V_scroll
L15:
L14:
MOV eax, DWORD [ebp - (12)]
PUSHD eax
MOV eax, DWORD [ebp - (16)]
PUSHD eax
CALL V_set_cursor_pos
ADD esp, 8
JMP L4
L5:
MOV eax, 80
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, DWORD [ebp - (-16)]
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 1
MOV cl, al
SHL DWORD [esp], cl
POP eax
PUSHD eax
MOV eax, 753664
ADD DWORD [esp], eax
POP eax
MOV DWORD [ebp - (4)], eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
MOV eax, 8
MOV cl, al
SHL DWORD [esp], cl
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (-20)]
MOVZX eax, BYTE[eax]
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, DWORD [ebp - (4)]
MOV ebx, DWORD [esp]
MOV WORD [eax], bx
ADD esp, 4
L4:
@@:
MOV esp, ebp
POP ebp
RET
V_printf:
PUSH ebp
MOV ebp, esp
L16:
MOV eax, DWORD [ebp - (-8)]
MOVZX eax, BYTE[eax]
PUSHD eax
MOV eax, 0
CMP DWORD [esp], eax
MOV eax, 0
SETNE al
ADD esp, 4
CMP eax, 0
JE L17
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, -1
PUSHD eax
MOV eax, 0
PUSHD eax
CALL V_putchar
ADD esp, 16
MOV eax, DWORD [ebp - (-8)]
INC eax
MOV DWORD [ebp - (-8)], eax
JMP L16
L17:
@@:
MOV esp, ebp
POP ebp
RET
V_sleep:
PUSH ebp
MOV ebp, esp
MOV eax, 0
PUSHD eax
L18:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 3145727
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L19
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L18
L19:
@@:
MOV esp, ebp
POP ebp
RET
V_build_idt:
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
	
@@:
MOV esp, ebp
POP ebp
RET
V_install_interrupt_handler:
PUSH ebp
MOV ebp, esp

	mov edi, DWORD [ebp + 12]
	shl edi, 3
	add edi, IDT_ADDRESS
	mov eax, DWORD [ebp + 8]         ; Load the address of the interrupt handler into EAX
	mov WORD [edi], ax               ; Store the lower 16 bits of the handler address in the IDT entry for interrupt 49
	
	add edi, 2
	mov WORD [edi], 008h             ; Store the code segment selector (needed for transitioning to code)
	
	add edi, 2
	mov WORD [edi], 08E00h           ; Set up the interrupt gate descriptor (08E00h means present, privilege level 0, interrupt gate)
	
	add edi, 2
	shr eax, 16                      ; Shift the high 16 bits of the handler address into AX
	mov [edi], ax                    ; Store the upper 16 bits of the handler address in the IDT entry for interrupt 49
	
@@:
MOV esp, ebp
POP ebp
RET
V_PIC_remap:
PUSH ebp
MOV ebp, esp
SUB esp, 4
SUB esp, 4
MOV eax, 33
PUSHD eax
CALL V_inb
ADD esp, 4
MOV BYTE [ebp - (4)], al
MOV eax, 161
PUSHD eax
CALL V_inb
ADD esp, 4
MOV BYTE [ebp - (8)], al
MOV eax, 32
PUSHD eax
MOV eax, 16
PUSHD eax
MOV eax, 1
OR DWORD [esp], eax
POP eax
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 160
PUSHD eax
MOV eax, 16
PUSHD eax
MOV eax, 1
OR DWORD [esp], eax
POP eax
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, DWORD [ebp - (-12)]
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, DWORD [ebp - (-8)]
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, 4
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, 2
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 33
PUSHD eax
MOV eax, 1
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 161
PUSHD eax
MOV eax, 1
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 33
PUSHD eax
MOVZX eax, BYTE [ebp - (4)]
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 161
PUSHD eax
MOVZX eax, BYTE [ebp - (8)]
PUSHD eax
CALL V_outb
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_PIC_mask:
PUSH ebp
MOV ebp, esp
MOV eax, 33
PUSHD eax
MOVZX eax, BYTE [ebp - (-12)]
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 161
PUSHD eax
MOVZX eax, BYTE [ebp - (-8)]
PUSHD eax
CALL V_outb
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_generic_interrupt_handler:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L20
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_install_generic_interrupt_handler:
PUSH ebp
MOV ebp, esp
MOV eax, 0
PUSHD eax
L21:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 256
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L22
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_generic_interrupt_handler
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L21
L22:
@@:
MOV esp, ebp
POP ebp
RET
V_except_default:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L23
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_null_div:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L24
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_overflow:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L25
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_double_fault:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L26
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_ss_fault:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L27
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_gpf:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L28
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_page_fault:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L29
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_except_float:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L30
PUSHD eax
CALL V_printf
ADD esp, 4

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_install_exception_interrupts:
PUSH ebp
MOV ebp, esp
MOV eax, 0
PUSHD eax
L31:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 32
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L32
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_except_default
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L31
L32:
MOV eax, 0
PUSHD eax
MOV eax, V_except_null_div
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 4
PUSHD eax
MOV eax, V_except_overflow
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 8
PUSHD eax
MOV eax, V_except_double_fault
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 12
PUSHD eax
MOV eax, V_except_ss_fault
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 13
PUSHD eax
MOV eax, V_except_gpf
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 14
PUSHD eax
MOV eax, V_except_page_fault
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, 16
PUSHD eax
MOV eax, V_except_float
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_master_irq_default:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L33
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_outb
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_slave_irq_default:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L34
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 160
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_outb
ADD esp, 8
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_outb
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_keyboard_handler:
PUSH ebp
MOV ebp, esp
pushad
MOV eax, L35
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L36
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 96
PUSHD eax
CALL V_inb
ADD esp, 4
PUSHD eax
CALL V_cstrub
ADD esp, 4
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L37
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 32
PUSHD eax
MOV eax, 32
PUSHD eax
CALL V_outb
ADD esp, 8

	popad
	mov esp, ebp
	pop ebp
	iret
	
@@:
MOV esp, ebp
POP ebp
RET
V_install_irq_interrupts:
PUSH ebp
MOV ebp, esp
MOV eax, 32
PUSHD eax
L38:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 32
PUSHD eax
MOV eax, 8
ADD DWORD [esp], eax
POP eax
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L39
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_master_irq_default
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L38
L39:
MOV eax, 40
MOV DWORD [ebp - (4)], eax
L40:
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, 40
PUSHD eax
MOV eax, 8
ADD DWORD [esp], eax
POP eax
CMP DWORD [esp], eax
MOV eax, 0
SETB al
ADD esp, 4
CMP eax, 0
JE L41
MOV eax, DWORD [ebp - (4)]
PUSHD eax
MOV eax, V_slave_irq_default
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
MOV eax, DWORD [ebp - (4)]
INC eax
MOV DWORD [ebp - (4)], eax
JMP L40
L41:
MOV eax, 32
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, V_keyboard_handler
PUSHD eax
CALL V_install_interrupt_handler
ADD esp, 8
@@:
MOV esp, ebp
POP ebp
RET
V_main:
PUSH ebp
MOV ebp, esp
include '..\main_source\constants.asm'
CALL V_init_vga
MOV eax, L42
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L43
PUSHD eax
CALL V_printf
ADD esp, 4
CALL V_build_idt
CALL V_install_generic_interrupt_handler
CALL V_install_exception_interrupts
CALL V_install_irq_interrupts
MOV eax, 32
PUSHD eax
MOV eax, 40
PUSHD eax
CALL V_PIC_remap
ADD esp, 8
MOV eax, 253
PUSHD eax
MOV eax, 255
PUSHD eax
CALL V_PIC_mask
ADD esp, 8
sti
MOV eax, 31
PUSHD eax
CALL V_set_terminal_color
ADD esp, 4
MOV eax, 1
PUSHD eax
CALL V_set_blinking
ADD esp, 4
MOV eax, L44
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 0
PUSHD eax
CALL V_set_blinking
ADD esp, 4
MOV eax, L45
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L46
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L47
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, 1
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
PUSHD eax
MOV eax, 2
PUSHD eax
MOV eax, 2
ADD DWORD [esp], eax
POP eax
CMP DWORD [esp], eax
MOV eax, 0
SETA al
ADD esp, 4
CMP eax, 0
JE L49
MOV eax, 1
PUSHD eax
MOV eax, 1
ADD DWORD [esp], eax
POP eax
JMP L48
L49:
MOV eax, 2
PUSHD eax
MOV eax, 2
ADD DWORD [esp], eax
POP eax
L48:
PUSHD eax
CALL V_cstrub
ADD esp, 4
PUSHD eax
CALL V_printf
ADD esp, 4
MOV eax, L50
PUSHD eax
CALL V_printf
ADD esp, 4
L51:
MOV eax, 1
CMP eax, 0
JE L52
hlt
JMP L51
L52:
MOV eax, 0
JMP @f
@@:
MOV esp, ebp
POP ebp
RET
V_terminal_color rb 1
L20 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L23 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L24 db 68, 105, 118, 105, 115, 105, 111, 110, 32, 98, 121, 32, 48, 13, 10, 0
L25 db 79, 118, 101, 114, 102, 108, 111, 119, 13, 10, 0
L26 db 68, 111, 117, 98, 108, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L27 db 83, 116, 97, 99, 107, 32, 115, 101, 103, 109, 101, 110, 116, 32, 102, 97, 117, 108, 116, 13, 10, 0
L28 db 71, 101, 110, 101, 114, 97, 108, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110, 32, 102, 97, 117, 108, 116, 13, 10, 0
L29 db 80, 97, 103, 101, 32, 102, 97, 117, 108, 116, 13, 10, 0
L30 db 70, 108, 111, 97, 116, 105, 110, 103, 32, 112, 111, 105, 110, 116, 32, 101, 120, 99, 101, 112, 116, 105, 111, 110, 13, 10, 0
L33 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L34 db 85, 110, 104, 97, 110, 100, 108, 101, 100, 32, 73, 82, 81, 32, 114, 101, 99, 101, 105, 118, 101, 100, 13, 10, 0
L35 db 75, 101, 121, 32, 112, 114, 101, 115, 115, 101, 100, 33, 13, 10, 0
L36 db 75, 101, 121, 32, 99, 111, 100, 101, 58, 32, 0
L37 db 13, 10, 0
L42 db 73, 110, 105, 116, 105, 97, 108, 105, 122, 105, 110, 103, 32, 116, 104, 101, 32, 115, 121, 115, 116, 101, 109, 46, 46, 46, 13, 10, 0
L43 db 83, 101, 116, 116, 105, 110, 103, 32, 117, 112, 32, 105, 110, 116, 101, 114, 114, 117, 112, 116, 115, 46, 46, 46, 13, 10, 0
L44 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 32, 98, 108, 105, 110, 107, 13, 10, 0
L45 db 84, 104, 105, 115, 32, 115, 104, 111, 117, 108, 100, 110, 39, 116, 13, 10, 0
L46 db 97, 108, 108, 32, 100, 111, 110, 101, 44, 32, 104, 97, 110, 103, 105, 110, 103, 13, 10, 0
L47 db 104, 101, 114, 101, 32, 105, 115, 32, 116, 104, 101, 32, 109, 97, 120, 32, 98, 101, 116, 119, 101, 101, 110, 32, 50, 32, 97, 110, 100, 32, 52, 58, 32, 0
L50 db 13, 10, 0
