; GDT
gdt_start:
gdt_null:                 ; Null descriptor (mandatory)
    dd 0x00000000         ; 8 bytes (64 bits) of zeros
    dd 0x00000000

gdt_code:                 ; Code Segment Descriptor (flat mode)
    dw 0xFFFF             ; Limit (bits 0-15) - 4 GB limit
    dw 0x0000             ; Base (bits 0-15) - Base address
    db 0x00               ; Base (bits 16-23)
    db 10011010b          ; 1st flags: Present, Privilege level 0, Code, Executable, Readable
    db 11001111b          ; 2nd flags: 32-bit, 4KB granularity, Limit (bits 16-19)
    db 0x00               ; Base (bits 24-31)

gdt_data:                 ; Data Segment Descriptor (flat mode)
    dw 0xFFFF             ; Limit (bits 0-15)
    dw 0x0000             ; Base (bits 0-15)
    db 0x00               ; Base (bits 16-23)
    db 10010010b          ; 1st flags: Present, Privilege level 0, Data, Read/Write
    db 11001111b          ; 2nd flags: 32-bit, 4KB granularity, Limit (bits 16-19)
    db 0x00               ; Base (bits 24-31)

gdt_end:

; GDT descriptor (to load into GDTR)
gdt_descriptor:
    dw gdt_end - gdt_start - 1   ; Size of GDT (size - 1)
    dd gdt_start                 ; Base address of GDT

; Segment offsets (used in bootloader to set CS, DS, SS, etc.)
CODE_SEG = gdt_code - gdt_start
DATA_SEG = gdt_data - gdt_start
