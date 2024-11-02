include 'constants.inc'

;a simple boot sector
;_____________________________________________________________
use16
org 0x7c00

jmp     0x0000:start            ; set CS to 0, just in case it's not already done
				; that also allows us to put the GDT at the
				; top and jump over it, so the labels are
				; defined in the rest of the code

include '..\boot\gdt.asm'

start:
mov     [BOOT_DRIVE], dl        ; save the boot drive for later

mov     ax, cs                  ; set all the segment registers to 0 to be coherent with the subsequent flat memory model
mov     es, ax
mov     ds, ax
mov     ss, ax

mov     bp, STACK_ADDRESS       ; set up the stack
mov     sp, bp

                                ; load the kernel inode
                                ; it is at address 1024 + 512 + 64 (bootloader + superblock + root inode)
mov     al, 1                   ; how many sectors to read
mov     bx, KERNEL_ADDRESS - 512; load the inode right behind the kernel
mov     ch, 0                   ; cylinder 0, head 0
mov     dh, 0
mov     cl, 4                   ; start reading from 512 + 1024 = 3 * 512
mov     dl, [BOOT_DRIVE]
mov     ah, 0x02
int     0x13

jc      disk_error              ; check carry flag or number of read sectors to ensure the read went well

cmp     al, 1                   ; ensure that we read the correct number of sectors
jne     disk_error

                                ; locate and load the kernel at KERNEL_ADDRESS
mov     al, BYTE [KERNEL_ADDRESS - 512 + 64 + 59] ; second inode
shl     al, 1                   ; sectors as defined by the fs are 1024b, and 512b according to the bios
mov     bx, KERNEL_ADDRESS
mov     ch, 0                   ; cylinder 0, head 1
mov     dh, 1                   ; every head covers 18 sectors, so 20 - 18 = 2
mov     cl, 4                   ; start reading from 512 + 1024 + 64 * 128 + 1024 = 21 * 512
mov     dl, [BOOT_DRIVE]
mov     ah, 0x02
int     0x13

jc      disk_error              ; check carry flag or number of read sectors to ensure the read went well

mov     ah, BYTE [KERNEL_ADDRESS - 512 + 64 + 59]
shl     ah, 1                   ; verify that we read the expected number of sectors
cmp     ah, al
jne     disk_error

.32bits_mode_switch:
cli

lgdt [gdt_descriptor]

mov eax, cr0
or  eax, 0x1
mov cr0, eax
jmp CODE_SEG:init_pm

;_____________________________________________________________
;error messages
disk_error:
mov     bx, MSG_ERR_DISK
call    print_string
jmp     $

;_____________________________________________________________
;16 bits data and includes

BOOT_DRIVE db 0
MSG_ERR_PROT_MODE:
db 'Error while trying to jump to protected mode',0
MSG_ERR_DISK:
db 'Error while reading disk',0

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

jmp     CODE_SEG:KERNEL_ADDRESS ; jump to the kernel code

;_____________________________________________________________
;padding and signature

TIMES 510-($-$$) DB 0
DW 0xAA55