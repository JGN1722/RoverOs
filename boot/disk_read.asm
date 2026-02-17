; Raw disk reading and ext2fs file loading

; Reads two sectors every time, because its primary use is reading ext2fs
; blocks, which are assumed to always be 1024 blocks wide.
; TODO: Since most of the time it reads blocks from the filesystem, and the
; ids of these blocks have to be multiplied by two, maybe I can do the shl
; in here. Might save a few bytes.
disk_read:

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

mov	ax, 0x0202
mov	bx, WORD [disk_buff]
mov	dl, BYTE [BOOT_DRIVE]

int	0x13
jc	disk_error

cmp	ax, 0x0002		; We gotta have al = 2, ah = 0
jne	disk_error		; Might as well do a single cmp

ret

MSG_ERR_DISK	db 'Disk read error',0
disk_error:
mov	si, MSG_ERR_DISK
jmp	print_string

; SMAX		db 0
; HMAX		db 0

; disk_buff	dw 0
; disk_LBA	dw 0
; disk_N	dw 0


; Places the data block pointers of the specified inode number in the
; designated array
open_file:

; First, load superblock, and get block size, inode size, inodes per group
mov	di, WORD [TMP_BUFF]
mov	WORD [disk_buff], di
mov	WORD [disk_LBA], 2
call	disk_read

; Ignore block size for now, hardcode it to 0x400
; As we're using ext2 rev 0 right now, inode size is always 128, too
mov	di, WORD [TMP_BUFF]
mov	bx, WORD [di + 40] ; inodes per group, low word

; Then, calculate the block group index
; bg_i = #inode / inodes_per_group
mov	eax, DWORD [INODE_NUM]
div	bx

pushw	ax

; Only load the first block of the BGDT, idc
mov	WORD [disk_buff], di
mov	WORD [disk_LBA], 4
call	disk_read

; Calculate the offset of the IT block, and load it
; #block = #inode / (block_size / inode_size)
; offset = #inode % (block_size / inode_size)

; Note that due to current simplifications, block_size / inode_size
; is a constant, equal to 8
mov	eax, DWORD [INODE_NUM]
mov	bx, 8
div	bx

; Look up the BGDT to get the block id of the corresponding inode tbl
popw	di
shl	di, 5
mov	bx, WORD [TMP_BUFF]

add	ax, WORD [bx + di + 8]
shl	ax, 1 ; Blocks are 1024 bytes, sectors are 512 bytes

pushw	dx

mov	WORD [disk_buff], bx
mov	WORD [disk_LBA], ax
call	disk_read

; Get the inode and fill the pointers
mov	bx, WORD [TMP_BUFF]

popw	si
shl	si, 7

mov	ax, WORD [bx + si + 28]
shr	ax, 1 ; Meh, block size is 1024
mov	WORD [block_count], ax

lea	si, [bx + si + 40]

mov	di, data_block_ptr_arr
mov	cx, 15 * 4
rep	movsb

mov	BYTE [current_block_index], 0

ret

; INODE_NUM dd 0
; TMP_BUFF dw 0

; current_block_index db 0 ; TODO: why just a byte ?
; data_block_ptr_arr dd 15


; To reduce complexity, throw an error when encountering a
; doubly indirect block or more
load_next_sect:

movzx	ecx, BYTE [current_block_index]

cmp	cx, 12
jb	.no_indirection

cmp	cx, 267
ja	disk_error

sub	sp, 0x400
mov	WORD [disk_buff], sp

mov	si, WORD [data_block_ptr_arr + 4 * 12]
shl	si, 1
mov	WORD [disk_LBA], si
call	disk_read

; This calculation is horrible, it's just a quick and dirty fix to commit
; before the end of the week. I'll fix it later.
movzx	si, BYTE [current_block_index]

sub	si, 12
shl	si, 2
add	si, sp

mov	si, WORD [si]

add	sp, 0x400

jmp	.proceed

.no_indirection:
mov	si, WORD [data_block_ptr_arr + 4 * ecx]

.proceed:
shl	si, 1
mov	di, WORD [TMP_BUFF]

mov	WORD [disk_buff], di
mov	WORD [disk_LBA], si
call	disk_read

inc	BYTE [current_block_index]

ret


; Assumes a directory is currently open
lookup_directory:

.new_block:

mov	bx, WORD [TMP_BUFF2]
mov	WORD [TMP_BUFF], bx
call	load_next_sect

mov	bx, WORD [TMP_BUFF2]
lea	dx, [bx + 0x400]

.new_entry:

cmp	bx, dx
je	.new_block

lea	si, [bx + 8]
mov	di, WORD [FILE_NAME]
movzx	cx, BYTE [bx + 6]

mov	ax, WORD [bx]
add	bx, WORD [bx + 4]

test	ax, ax
jz	.new_entry

repne	cmpsb
je	.end

jmp	.new_entry

.end:

ret


load_file:

mov	bx, WORD [DEST_BUFF]
mov	cx, WORD [block_count]

.next_block:

push	cx
push	bx

mov	WORD [TMP_BUFF], bx
call	load_next_sect

pop	bx
add	bh, 0x4

test	bx, bx
jnz	.no_overflow

mov	ax, es
add	ah, 0x10
mov	es, ax

.no_overflow:

pop	cx

loopw	.next_block

xor	ax, ax
mov	es, ax

ret
