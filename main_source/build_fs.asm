format PE console
entry start
include 'C:\Users\comedelfini--thibaud\Desktop\fasm\INCLUDE\win32a.inc'

boot_sect_size  equ 512
superblock_size equ 1024
block_size      equ 1024
inode_size      equ 64
inode_number    equ 128
total_size      equ superblock_size + inode_size * inode_number

section '.data' data readable writeable
        hHeap dd 0
        hBuff dd 0
        
        fileHandle   dd 0
        bytesWritten dd 0
        kernelsize   dd 0
        
        fileName    db 'C:\Users\comedelfini--thibaud\Desktop\RoverOs\image\fs.bin', 0
        kernel_file db 'C:\Users\comedelfini--thibaud\Desktop\RoverOs\image\kernel.bin', 0
        kernel_name db 'KERNEL',0
        kernel_ext  db 'BIN',0
        
        superblock_placeholder db 0xCA

        inode_start dd 0 ; a place to store the address, so as not to recalculate it all the time

section '.code' code readable executable
start:
        invoke  GetProcessHeap,0
        mov     [hHeap], eax
        
        invoke  HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,total_size
        mov     [hBuff], eax

        ; fill the superblock
        ; just dummy data right now
        mov     edi, eax
        mov     ecx, superblock_size
        mov     al , BYTE [superblock_placeholder]
        rep     stosb
        
        ;fill the inodes
        ;inodes format:
        ; - 0       -> 0 if unused, 1 if used
        ; - 1  - 55 -> file name
        ; - 56 - 58 -> file ext
        ; - 59      -> number of blocks
        ; - 60 - 63 -> data pointer
        
        ;two inodes are to be filled:
        ; - the root folder inode, which is the first
        ; - the kernel file inode, which is the second

populate_root_inode:
        mov     edi, [hBuff]
        add     edi, superblock_size
        mov     [inode_start], edi

        ; root has no name and no extension
        ; every directory only has one block
        ; the data pointer points to the block
        ; in the block, every byte is the inode number of a file
        ; 0 indicates no file

        add     edi, 60
        mov     DWORD [edi], total_size + boot_sect_size

        mov     eax, total_size
        add     eax, block_size
        invoke  HeapReAlloc,[hHeap],HEAP_ZERO_MEMORY,[hBuff],eax
        mov     [hBuff], eax

        ; poke the kernel inode number to the root data
        mov     edi, [hBuff]
        add     edi, total_size
        mov     BYTE [edi], 1

populate_kernel_inode:

        mov     edi, [hBuff]
        add     edi, superblock_size + inode_size
        mov     [inode_start], edi

        ; first, count the chars in the kernel name
        mov     ecx, 55 ; max length
        mov     edi, kernel_name
        mov     eax, 0
        repne   scasb
        mov     ebx, 54
        sub     ebx, ecx
        
        ; it starts at [hBuff + 1024 + 64]
        mov     edi, [inode_start]
        mov     BYTE [edi], 1
        inc     edi
        
        ; place the name
        mov     ecx, ebx
        mov     esi, kernel_name
        rep     movsb
        
        ; place the extension
        mov     edi, [inode_start]
        add     edi, 56
        mov     ecx, 3
        mov     esi, kernel_ext
        rep     movsb
        
        ; calculate the number of blocks needed for the kernel code,
        ; allocate them, then poke the number
        ; first thing first, read the kernel file size
        invoke  CreateFile, kernel_file, GENERIC_READ, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov     [fileHandle], eax
        invoke  GetFileSize, eax, NULL
        
        ; calculate the needed space by rounding the value to the nearest upper 1024
        add     eax, 1023
        and     eax, 0xFFFFFC00
        mov     [kernelsize], eax
        mov     edi, [inode_start]
        add     edi, 59
        shr     eax, 10         ;divide by 1024 to get the block number
        mov     BYTE [edi], al  ;max #blocks is 256
        
        ; allocate the space in the buffer
        ; TODO : allocate a whole number of blocks, even if
        ;        some padding is automatically done by the
        ;        os
        mov     eax, total_size
        add     eax, block_size ; the block of the root inode data
        add     eax, [kernelsize]
        invoke  HeapReAlloc,[hHeap],HEAP_ZERO_MEMORY,[hBuff],eax
        mov     [hBuff], eax
        mov     edi, eax
        add     edi, total_size
        
        ; poke the data pointer
        ; kernel data is right behind the inode table
        mov     eax, [inode_start]
        add     eax, 60
        mov     DWORD [eax], total_size + 512
        
        ; read the data to the file
        mov     ecx, [kernelsize]
        mov     edi, [hBuff]
        add     edi, total_size
        add     edi, block_size
        invoke  ReadFile,[fileHandle],edi,ecx,NULL,NULL
        
        ; last, close the kernel file handle
        invoke  CloseHandle, [fileHandle]
        
        ; Create a file to write the data
        invoke  CreateFile, fileName, GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        mov     [fileHandle], eax

        ; Check if file was created successfully
        test    eax, eax
        jz      .error

        ; Write the buffer to the file
        mov     ecx, total_size
        add     ecx, block_size
        add     ecx, [kernelsize]
        invoke  WriteFile, [fileHandle], [hBuff], ecx, bytesWritten, 0

        ; Close the file handle
        invoke  CloseHandle, [fileHandle]

        ; Exit the program
        invoke  ExitProcess, 0

.error:
        invoke  ExitProcess, -1
        
section '.import' import data readable
        library kernel32, 'kernel32.dll'
        import  kernel32, \
                   GetProcessHeap, 'GetProcessHeap',\
                   HeapAlloc, 'HeapAlloc',\
                   HeapReAlloc, 'HeapReAlloc',\
                   CreateFile, 'CreateFileA', \
                   ReadFile, 'ReadFile',\
                   GetFileSize, 'GetFileSize',\
                   WriteFile, 'WriteFile', \
                   CloseHandle, 'CloseHandle', \
                   ExitProcess, 'ExitProcess'
