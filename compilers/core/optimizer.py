"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The final stage of the compiler, a peephole optimizer to atone for my lack of optimized asm generation
"""

import re
import copy

from core.helpers import *

def remove_jmp_label(code: str) -> str:
	pattern = re.compile(r'JMP	(\w+)\n\1:\n')
	return pattern.sub(r'\1:\n', code)

def remove_jmp_anonymous(code: str) -> str:
	pattern = re.compile(r'JMP	@f\n@@:\n')
	return pattern.sub('@@:\n', code)

def remove_mov_push(code: str) -> str:
	pattern = re.compile(r'MOV	eax, (.+)\nPUSHD	eax\n')
	return pattern.sub(r'PUSHD	\1\n', code)

def remove_mov_cmp(code: str) -> str:
	pattern_1 = re.compile(r'MOV	eax, (.+)\nCMP	eax, (-?\d+)\n')
	pattern_2 = re.compile(r'MOVZX	eax, (.+)\nCMP	eax, (-?\d+)\n')
	code = pattern_1.sub(r'CMP	\1, \2\n', code)
	return pattern_2.sub(r'CMP	\1, \2\n', code)

def remove_pop_push(code: str) -> str:
	pattern = re.compile('POP	eax\nPUSHD	eax\n')
	return pattern.sub(r'', code)

def Peephole(asm):
	asm = remove_jmp_label(asm)
	asm = remove_jmp_anonymous(asm)
	asm = remove_mov_push(asm)
	asm = remove_pop_push(asm)
	# asm = remove_mov_cmp(asm) # Doesn't work with Switch()
	return asm

def FoldConstants(AST):
	if not isinstance(AST, ASTNode):
		return copy.copy(AST)
	elif AST.type != "BinaryOp" and AST.type != "Relation" and AST.type != "PrefixUnaryOp":
		return ASTNode(type_=AST.type, value=AST.value, children=[FoldConstants(child) for child in AST.children])
	
	if AST.type == "PrefixUnaryOp":
		child = FoldConstants(AST.children[0])
		if child.type == "Number":
			return ASTNode(type_="Number", value=~(child.value) & 0xFFFFFFFF)
		return ASTNode(type_=AST.type, value=AST.value, children=[FoldConstants(child) for child in AST.children])
	
	child1 = FoldConstants(AST.children[0])
	child2 = FoldConstants(AST.children[1])
	
	if child1.type == "Number" and child2.type == "Number":
		# Binary operations
		if AST.value == "+":
			return ASTNode(type_="Number", value=child1.value+child2.value)
		elif AST.value == "-":
			return ASTNode(type_="Number", value=child1.value-child2.value)
		elif AST.value == "*":
			return ASTNode(type_="Number", value=child1.value*child2.value)
		elif AST.value == "%":
			return ASTNode(type_="Number", value=child1.value%child2.value)
		elif AST.value == "/":
			return ASTNode(type_="Number", value=child1.value//child2.value)
		elif AST.value == ">>":
			return ASTNode(type_="Number", value=child1.value>>child2.value)
		elif AST.value == "<<":
			return ASTNode(type_="Number", value=child1.value<<child2.value)
		elif AST.value == "&":
			return ASTNode(type_="Number", value=child1.value&child2.value)
		elif AST.value == "|":
			return ASTNode(type_="Number", value=child1.value|child2.value)
		# Relations
		if AST.value == "==":
			return ASTNode(type_="Number", value=1 if child1.value == child2.value else 0)
		elif AST.value == "!=":
			return ASTNode(type_="Number", value=1 if child1.value != child2.value else 0)
		elif AST.value == ">=":
			return ASTNode(type_="Number", value=1 if child1.value >= child2.value else 0)
		elif AST.value == "<=":
			return ASTNode(type_="Number", value=1 if child1.value <= child2.value else 0)
		elif AST.value == ">":
			return ASTNode(type_="Number", value=1 if child1.value > child2.value else 0)
		elif AST.value == "<":
			return ASTNode(type_="Number", value=1 if child1.value < child2.value else 0)
	
	return ASTNode(type_=AST.type, value=AST.value, children=[FoldConstants(child) for child in AST.children])
