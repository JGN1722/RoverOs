include 'c:\users\comedelfini--thibaud\desktop\RoverOs\main_source\constants.inc'

;a simple boot sector
;_____________________________________________________________
use16
org 0x7c00

jmp     0x0000:start            ; set CS to 0, just in case it's not already done

start:
mov     [BOOT_DRIVE], dl        ; save the boot drive for later

mov     ax, cs                  ; set all the segment registers to 0 to be coherent with the subsequent flat memory model
mov     es, ax
mov     ds, ax
mov     ss, ax

mov     bp, STACK_ADDRESS       ; set up the stack
mov     sp, bp

mov     bx, MSG_REAL_MODE       ; inform the user that the bootloader started successfully
call    print_string

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

call    switch_to_pm

;_____________________________________________________________
;infinite loop

jmp     $

;_____________________________________________________________
;error messages
disk_error:
mov     bx, MSG_ERR_DISK
call    print_string
jmp     $

;_____________________________________________________________
;16 bits data and includes

BOOT_DRIVE db 0
MSG_REAL_MODE:
db 'Jumping to protected mode...',0
MSG_ERR_PROT_MODE:
db 'Error while trying to jump to protected mode',0
MSG_ERR_DISK:
db 'Error while reading disk',0

include 'c:\users\comedelfini--thibaud\desktop\RoverOs\boot\io\print_string.asm'
include 'c:\users\comedelfini--thibaud\desktop\RoverOs\boot\pm\gdt.asm'
include 'c:\users\comedelfini--thibaud\desktop\RoverOs\boot\pm\switch_to_pm.asm'

;_____________________________________________________________
;real mode code
use32

BEGIN_PM:
call    hide_bios_cursor

mov     ebx, MSG_PROT_MOD
call    print_string_pm

jmp     CODE_SEG:KERNEL_ADDRESS ; jump to the kernel code

jmp     $                       ; hang if we ever return from the kernel

;_____________________________________________________________
;32 bits data and includes
include 'c:\users\comedelfini--thibaud\desktop\RoverOs\boot\pm\io_pm.asm'

MSG_PROT_MOD:
db 'Starting protected mode...',0
;_____________________________________________________________
;padding and signature

TIMES 510-($-$$) DB 0
DW 0xAA55