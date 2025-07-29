include '..\boot\constants.asm'

;a simple boot sector
;_____________________________________________________________
use16
org 0x7c00

jmp	0x0000:start		; set CS to 0, just in case it's not already done
				; that also allows us to put the GDT at the
				; top and jump over it, so the labels are
				; defined in the rest of the code

include '..\boot\bpb.asm'	; so the bios does not yell at me
include '..\boot\gdt.asm'

start:
mov	[BOOT_DRIVE], dl	; save the boot drive for later

mov	ax, cs			; set all the segment registers to 0 to be coherent with the subsequent flat memory model
mov	es, ax
mov	ds, ax
mov	ss, ax

mov	ax, 0003h 		; set the video mode on 03h manually, just
int	10h			; to be sure

				; load the kernel inode
				; it is at address 1024 + 512 + 64 (bootloader + superblock + root inode)
mov	al, 1			; how many sectors to read
mov	bx, 0x7c00 + 512	; load the inode there
mov	ch, 0			; cylinder 0, head 0
mov	dh, 0
mov	cl, 4			; start reading from 512 + 1024 = 3 * 512
mov	dl, [BOOT_DRIVE]
mov	ah, 0x02
int	0x13

jc	disk_error		; check carry flag or number of read sectors to ensure the read went well

cmp	al, 1			; ensure that we read the correct number of sectors
jne	disk_error

				; locate and load the kernel at KERNEL_ADDRESS
mov	al, BYTE [KERNEL_ADDRESS - 512 + 64 + 59] ; second inode
shl	al, 1			; sectors as defined by the fs are 1024b, and 512b according to the bios
mov	bx, KERNEL_ADDRESS
mov	ch, 0			; cylinder 0, head 1
mov	dh, 1			; every head covers 18 sectors, so 20 - 18 = 2
mov	cl, 4			; start reading from 512 + 1024 + 64 * 128 + 1024 = 21 * 512
mov	dl, [BOOT_DRIVE]
mov	ah, 0x02
int	0x13

jc	disk_error		; check carry flag or number of read sectors to ensure the read went well

mov	ah, BYTE [KERNEL_ADDRESS - 512 + 64 + 59]
shl	ah, 1			; verify that we read the expected number of sectors
cmp	ah, al
jne	disk_error

.get_mem_map:			; get the memory map
				; most of this code is copied straight from the osdev wiki
				; and I have no idea how it works for the biggest part
mov	DWORD [MEM_MAP_ADDRESS], 0
mov	di, MEM_MAP_ENTRIES_START
xor	ebx, ebx
xor	bp, bp
mov	edx, 0x0534d4150	; this number is called "SMAP" for some reason
mov	eax, 0xe820
mov	DWORD [es:di + 20], 1	; "force a valid ACPI 3.x entry" in the wiki, no idea why
mov	ecx, 24
int	0x15

jc	mem_error		; function not supported

mov	edx, 0x0534d4150
cmp	eax, edx
jne	mem_error

test	ebx, ebx
je	mem_error

.get_next_entry:
mov	eax, 0xe820
mov	ecx, 24
int	0x15
jc	.end_mem_map		 ; end of list already reached

mov	edx, 0x0534d4150

.process_mem_map_entry:
jcxz	.skip_entry

cmp	cl, 20
jbe	.notext 		; ACPI entry ?

test	BYTE [es:di + 20], 1	; if so, is the ignore flag set ?
je	.skip_entry

.notext:
mov	ecx, [es:di + 8]
or	ecx, [es:di + 12]
jz	.skip_entry

inc	bp
add	di, 24

.skip_entry:
test	ebx, ebx
jne	.get_next_entry

.end_mem_map:
mov	WORD [MEM_MAP_ADDRESS], bp; it's a DWORD, but only the low word is set at most
mov     WORD [MEM_MAP_ADDRESS + 2], 0
clc				; the carry flag is set when we reach the end of the list

.32bits_mode_switch:
cli

lgdt [gdt_descriptor]

mov eax, cr0
or  eax, 0x1
mov cr0, eax
jmp CODE_SEG:init_pm

;_____________________________________________________________
;infinite loop
hang:
jmp $

;_____________________________________________________________
;error messages
disk_error:
mov	bx, MSG_ERR_DISK
jmp	print_string

mem_error:
mov	bx, MSG_ERR_MEM
jmp	print_string

;_____________________________________________________________
;16 bits data and includes

BOOT_DRIVE db 0
MSG_ERR_PROT_MODE:
db 'Error: 32 bits mode not supported',0
MSG_ERR_DISK:
db 'Error while reading disk',0
MSG_ERR_MEM:
db 'Error while detecting RAM',0

include '..\boot\print_string.asm'

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
;padding, partition table and signature
BOOT_SECT_CODE_SIZE = 510 ; 446 if the partition table is included

times BOOT_SECT_CODE_SIZE-($-$$) db 0

;include '..\boot\partition_table.asm'

dw 0xAA55