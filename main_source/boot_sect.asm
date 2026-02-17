KERNEL_ADDRESS = 0x8000
TMP_DISK_DATA1 = 0x8000 ; Only used before kernel load
TMP_DISK_DATA2 = 0x5000 ; Far enough, or so I hope
STACK_ADDRESS = 0x7a00
MEM_MAP_ADDRESS = 0x2000
MEM_MAP_ENTRIES_START = MEM_MAP_ADDRESS + 4

; Map of low memory:
;
; +-------------+ 0xf0000
; |reserved	|
; +-------------+ 0x80000
; |empty	| <- Large enough for now
; +-------------+ ...
; |kernel	|
; +-------------+ 0x8000
; |stage 2 boot |
; +-------------+ 0x7e00
; |stage 1 boot |
; +-------------+ 0x7c00
; |boot data	|
; +-------------+ 0x7a00
; |stack	|
; +-------------+ ...
; |empty	| <- No collision should occur, there's enough space
; +-------------+ ...
; |memory map	|
; +-------------+ 0x2000
; |paging data	| <- Only created after 32-bit mode switch
; +-------------+ 0x0000

; To save space in the boot sector, uninitialized data like empty variables
; are put in the 'boot data' part. Here are their addresses:

; Main code data
BOOT_DRIVE = 0x7a00 ; byte

; disk read data
SMAX	= 0x7a01 ; byte
HMAX	= 0x7a02 ; byte

disk_buff	= 0x7a04 ; word
disk_LBA	= 0x7a06 ; word
disk_N		= 0x7a08 ; word

DEST_BUFF	= 0x7a0a ; word
INODE_NUM	= 0x7a0c ; dword
TMP_BUFF	= 0x7a10 ; word
TMP_BUFF2	= 0x7a12 ; word
FILE_NAME	= 0x7a14 ; word

current_block_index	= 0x7a16 ; byte
data_block_ptr_arr	= 0x7a18 ; 15 dwords
block_count		= 0x7a54 ; word


; a simple boot sector
;_____________________________________________________________
use16
org 0x7c00

jmp	0x0000:start

; include '..\boot\bpb.asm'

start:

cld

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

xor	ax, ax
mov	es, ax				; the interrupt trashes es

mov	ax, 0003h			; set VGA video mode
int	10h

mov	WORD [disk_buff], 0x7c00	; read the second stage
mov	WORD [disk_LBA], 0		; the function reads 2 sects every time
call	disk_read

mov	ah, 0x0e
mov	si, LOAD_MSG

.print_next_char:
lodsb
cmp	al, 0
je	.end
int	0x10
jmp	.print_next_char
.end:

jmp	stage2

;_____________________________________________________________
;16 bits data and includes

; BOOT_DRIVE	db 0

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

LOAD_MSG	db 'Loading kernel...',0
KERNEL_FILE	db 'kernel.bin',0

include '..\boot\gdt.asm'

stage2:

; Load the kernel
mov	WORD [INODE_NUM], 0
mov	WORD [TMP_BUFF], TMP_DISK_DATA1
call	open_file

mov	WORD [TMP_BUFF2], TMP_DISK_DATA1
mov	WORD [FILE_NAME], KERNEL_FILE
call	lookup_directory

mov	WORD [INODE_NUM], ax
mov	WORD [TMP_BUFF], TMP_DISK_DATA1
call	open_file

mov	WORD [DEST_BUFF], KERNEL_ADDRESS
call	load_file

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

cmp	eax, 0x534d4150
jne	mem_error

test	ebx, ebx
je	mem_error

add	di, 24

.get_next_entry:
mov	DWORD [es:di + 20], 1
mov	edx, 0x534d4150
mov	eax, 0xe820
mov	ecx, 24
int	0x15
jc	.end_mem_map

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
jmp	print_string

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

higher_half:
; Setup placeholder paging structures at 0x00000000
mov	ecx, 0x800
mov	eax, 0x00000002
mov	edi, 0x00000000
rep	stosd

; Identity map the first 4Mib
mov	ecx, 0x400
mov	edi, 0x00001000
mov	eax, 0x00000003
.fill_pt:
mov	DWORD [edi], eax
add	eax, 0x1000
add	edi, 4
loop	.fill_pt

mov	DWORD [0x00000000], 0x00001003
mov	DWORD [0x00000c00], 0x00001003
mov	DWORD [0x00000ffc], 0x00000003 ; recursive mapping

mov	eax, 0x00000000
mov	cr3, eax

mov	eax, cr0
or	eax, 0x80000000
mov	cr0, eax

jmp	CODE_SEG:.continue + 0xc0000000

.continue:
mov	DWORD [0x00000000], 0x00000002

add	ebp, 0xc0000000
add	esp, 0xc0000000

; jump to the kernel code
jmp	CODE_SEG:KERNEL_ADDRESS + 0xc0000000

;_____________________________________________________________
;padding
STAGE_2_SIZE = 512

times BOOT_SECT_SIZE+STAGE_2_SIZE-($-$$) db 0
