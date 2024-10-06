use32

VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
        pusha
        
        call    clear_screen
        
        mov     edx, VIDEO_MEMORY
.print_string_pm_loop:
        mov     al, [ebx]
        mov     ah, WHITE_ON_BLACK
        cmp     al, 0
        je      .print_string_pm_done
        mov     [edx], ax
        add     ebx, 1
        add     edx, 2
        jmp     .print_string_pm_loop
.print_string_pm_done :
        popa
        ret

hide_cursor:
        pusha
        mov     dx, 0x3D4
        mov     al, 0x0A
        out     dx, al
        inc     dx
        mov     al, 0x20
        out     dx, al
        popa
        ret

clear_screen:
        pusha
        mov     edi, VIDEO_MEMORY
        mov     ecx, 80 * 25          ; Number of character cells (80x25 screen)
        mov     ax, 0x0F20            ; White on black space character (0x20 with attribute 0x0F)
        rep     stosw                 ; Fill video memory with ' ' (0x20) and attribute (0x0F)
        popa
        ret