include 'C:\Users\comedelfini--thibaud\Desktop\RoverOs\main_source\constants.inc'

use32
org KERNEL_ADDRESS

mov     ebx, HELLO_MSG
call    print_string_pm

jmp     $

HELLO_MSG db 'Hello from the kernel!',0

include 'C:\Users\comedelfini--thibaud\Desktop\RoverOs\kernel\io\io.asm'