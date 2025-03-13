"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The final stage of the compiler, a peephole optimizer to atone for my lack of optimized asm generation
"""

import re

from core.helpers import *

def remove_jmp_label(code: str) -> str:
    pattern = re.compile(r'JMP (\w+)\n\1:\n')
    return pattern.sub(r'\1:\n', code)

def remove_jmp_anonymous(code: str) -> str:
    pattern = re.compile(r'JMP @f\n@@:\n')
    return pattern.sub('@@:\n', code)

def remove_mov_push(code: str) -> str:
    pattern = re.compile(r'MOV eax, (.+)\nPUSHD eax\nMOV eax, (.+)\n')
    return pattern.sub(r'PUSHD \1\nMOV eax, \2\n', code)

def Optimize(asm):
	asm = remove_jmp_label(asm)
	asm = remove_jmp_anonymous(asm)
	asm = remove_mov_push(asm)
	return asm