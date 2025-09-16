KERNEL_ADDRESS = 0x8000
STACK_ADDRESS = 0x7c00
MEM_MAP_ADDRESS = 0x600
MEM_MAP_ENTRIES_START = MEM_MAP_ADDRESS + 4

; a simple boot sector
;_____________________________________________________________
use16
org 0x7c00

jmp	0x0000:start

include '..\boot\bpb.asm'

start:

cli
mov	ax, cs
mov	es, ax
mov	ds, ax
mov	ss, ax
sti

mov	[BOOT_DRIVE], dl

mov	bp, STACK_ADDRESS
mov	sp, bp

mov	ah, 0x08			; get drive geometry
int	0x13
jc	disk_error

inc	dh
mov	BYTE [HMAX], dh
and	cl, 0x3f
mov	BYTE [SMAX], cl

mov	ax, 0
mov	es, ax				; the interrupt trashes es

mov	ax, 0003h			; set VGA video mode
int	10h

mov	WORD [disk_buff], 0x7e00	; read the second stage
mov	WORD [disk_LBA], 1
mov	BYTE [disk_N], 1
call	disk_read

mov	WORD [disk_buff], 0x8000	; load the second inode
mov	WORD [disk_LBA], 4		; inode array base address (5th sector)
mov	BYTE [disk_N], 1
call	disk_read

mov	al, BYTE [0x8000 + 64 + 59]	; second inode, offset 59 contains kernel length
shl	al, 1				; sectors for bios are 512b, but 1024b for fs
mov	WORD [disk_buff], KERNEL_ADDRESS
mov	WORD [disk_LBA], 2 + 2 + 16 + 2	; second file content start address
mov	BYTE [disk_N], al		; (and the kernel is always the second file)
call	disk_read

jmp	stage2

;_____________________________________________________________
;16 bits data and includes

BOOT_DRIVE	db 0

include '..\boot\print_string.asm'
; include '..\boot\print_hex.asm'
include '..\boot\disk_read.asm'

;_____________________________________________________________
;padding, partition table and signature
BOOT_SECT_CODE_SIZE = 510 ; 446 if the partition table is included
BOOT_SECT_SIZE = 512

times BOOT_SECT_CODE_SIZE-($-$$) db 0

;include '..\boot\partition_table.asm'

dw 0xaa55

;_____________________________________________________________
;second stage of the bootloader

include '..\boot\gdt.asm'

stage2:

; mostly a copy of the example from the osdev wiki
; I changed it a bit and corrected a mistake, though
get_mem_map:
mov	DWORD [MEM_MAP_ADDRESS], 1
mov	di, MEM_MAP_ENTRIES_START
xor	ebx, ebx
mov	edx, 0x534d4150
mov	eax, 0xe820
mov	DWORD [es:di + 20], 1
mov	ecx, 24
int	0x15

jc	mem_error

mov	edx, 0x534d4150
cmp	eax, edx
jne	mem_error

test	ebx, ebx
je	mem_error

add	di, 24

.get_next_entry:
mov	DWORD [es:di + 20], 1
mov	eax, 0xe820
mov	ecx, 24
int	0x15
jc	.end_mem_map

mov	edx, 0x534d4150

.process_mem_map_entry:
jcxz	.skip_entry

cmp	cl, 20
jbe	.notext

test	BYTE [es:di + 20], 1
je	.skip_entry

.notext:
mov	ecx, [es:di + 8]
or	ecx, [es:di + 12]
jz	.skip_entry

inc	DWORD [MEM_MAP_ADDRESS]
add	di, 24

.skip_entry:
test	ebx, ebx
jne	.get_next_entry

.end_mem_map:
clc

_32bits_mode_switch:
cli

lgdt [gdt_descriptor]

mov eax, cr0
or  eax, 0x1
mov cr0, eax
jmp CODE_SEG:init_pm

MEM_ERR_MSG	db 'Error while detecting RAM',0
mem_error:
	mov	si, MEM_ERR_MSG
	call	print_string

;_____________________________________________________________
;real mode code
use32

init_pm:
mov	ax, DATA_SEG
mov	ds, ax
mov	ss, ax
mov	es, ax
mov	fs, ax
mov	gs, ax

mov	ebp, STACK_ADDRESS
mov	esp, ebp

jmp	CODE_SEG:KERNEL_ADDRESS ; jump to the kernel code

;_____________________________________________________________
;padding
STAGE_2_SIZE = 512

times BOOT_SECT_SIZE+STAGE_2_SIZE-($-$$) db 0
