disk_read:

.read_sect:
cmp	BYTE [disk_N], 0
je	.end

mov	ax, WORD [disk_LBA]
mov	bl, BYTE [SMAX]
div	bl

mov	cl, ah
inc	cl

mov	ah, 0
mov	bl, BYTE [HMAX]
div	bl

mov	dh, ah
mov	ch, al

mov	ax, 0x0201
mov	bx, WORD [disk_buff]
mov	dl, BYTE [BOOT_DRIVE]

int	0x13
jc	disk_error

cmp	ax, 1			; We gotta have al = 1, ah = 0
jne	disk_error		; Might as well do a single cmp

inc	WORD [disk_LBA]
dec	BYTE [disk_N]
add	WORD [disk_buff], 512

cmp	WORD [disk_buff], 0x200
jae	.read_sect

mov	ax, es
add	ax, 0x1000
mov	es, ax

jmp	.read_sect

.end:

xor	ax, ax
mov	es, ax
ret

MSG_ERR_DISK	db 'Disk read error',0
disk_error:
mov	si, MSG_ERR_DISK
jmp	print_string

counter		dw 0

SMAX		db 0
HMAX		db 0

disk_buff	dw 0
disk_LBA	dw 0
disk_N		db 0