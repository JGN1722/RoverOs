; the first inodes will be loaded 512 bytes before the
; kernel code
; we must ensure that these 512 bytes don't overwrite
; anything important, the bootloader for instance
KERNEL_ADDRESS equ 0x7e00 + 512
STACK_ADDRESS equ 0x520