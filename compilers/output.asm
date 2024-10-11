use32
org 32768
JMP V_MAIN
V_CLEAR_SCREEN:
PUSH ebp
MOV ebp, esp
SUB esp, 16
MOV eax, 0xB8000
MOV DWORD [ebp - 4], eax
MOV eax, 0x0f
MOV DWORD [ebp - 8], eax
MOV eax, 80
PUSHD eax
MOV eax, 25
IMUL DWORD [esp]
ADD esp, 4
MOV DWORD [ebp - 12], eax
MOV eax, 0
MOV DWORD [ebp - 16], eax
L0:
MOV eax, DWORD [ebp - 16]
PUSHD eax
MOV eax, DWORD [ebp - 12]
MOV ebx, DWORD [esp]
ADD esp, 4
CMP ebx, eax
MOV eax, 0
SETB al
IMUL eax, 0xFFFFFFFF
TEST eax, eax
JZ L1
MOV eax, DWORD [ebp - 8]
PUSHD eax
MOV eax, 256
IMUL DWORD [esp]
ADD esp, 4
PUSHD eax
MOV eax, 32
ADD eax, DWORD [esp]
ADD esp, 4
MOV ebx, DWORD [ebp - 4]
MOV WORD [ebx], ax
MOV eax, 2
ADD DWORD [ebp - 4], eax
INC DWORD [ebp - 16]
JMP L0
L1:
RET_CLEAR_SCREEN:
MOV esp, ebp
POP ebp
RET
V_MAIN:
PUSH ebp
MOV ebp, esp
SUB esp, 8
MOV eax, 0xB8000
MOV DWORD [ebp - 4], eax
MOV eax, 0x0f
MOV DWORD [ebp - 8], eax
CALL V_CLEAR_SCREEN
MOV eax, 66
MOV ebx, DWORD [ebp - 4]
MOV BYTE [ebx], al
INC DWORD [ebp - 4]
MOV eax, DWORD [ebp - 8]
MOV ebx, DWORD [ebp - 4]
MOV BYTE [ebx], al
L2:
JMP L2
L3:
RET_MAIN:
MOV esp, ebp
POP ebp
RET
