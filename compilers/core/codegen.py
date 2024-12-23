"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: A set of code generator functions for use by the transpiler
"""

from core.helpers import *

# Utilities
output = ""
output += "use32\n"
output += "org " + str(0x7c00 + 512 + 512) + "\n"

output_data = ""

def Emit(s):
	global output
	
	output += s

def EmitLn(s):
	Emit(s + "\n")

def EmitLnData(s):
	global output_data
	
	output_data += s + "\n"

def GetOutput():
	return output + output_data


# Code Generators


# Functions
def FunctionHeader():
	EmitLn("PUSH ebp")
	EmitLn("MOV ebp, esp")

def FunctionFooter():
	EmitLn("MOV esp, ebp")
	EmitLn("POP ebp")
	EmitLn("RET")

def CallFunction(n):
	EmitLn("CALL V_" + n)


# Expressions
def PushMain():
	EmitLn("PUSHD eax")

def IncrementMain():
	EmitLn("INC eax")

def DecrementMain():
	EmitLn("DEC eax")

def NegateMain():
	EmitLn("NEG eax")

def AddMainStackTop():
	EmitLn("ADD eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def SubMainStackTop():
	EmitLn("SUB DWORD [esp], eax")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def MulMainStackTop():
	EmitLn("IMUL DWORD [esp]")
	EmitLn("ADD esp, 4")

def DivMainStackTop():
	EmitLn("MOV ebx, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")

def ModMainStackTop():
	EmitLn("MOV ebx, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")
	EmitLn("MOV eax, edx")

def ShlMainStackTop():
	EmitLn("MOV cl, al")
	EmitLn("SHL DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def ShrMainStackTop():
	EmitLn("MOV cl, al")
	EmitLn("SHR DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def AndMainStackTop():
	EmitLn("AND eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def OrMainStackTop():
	EmitLn("OR eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def XorMainStackTop():
	EmitLn("XOR eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def MainToStackTop():
	EmitLn("MOV DWORD [esp], eax")

def DereferenceMain(size):
	# I know we said no logic in the code generators, but this one is needed
	# TODO: Use string manipulation to remove this condition
	if size == 4:
		EmitLn("MOV eax, DWORD [eax]")
	else:
		EmitLn("MOVZX eax, " + GetSizeQualifier(size) + "[eax]")

def StoreDereferenceMain(size):
	if size == 4:
		EmitLn("MOV ebx, DWORD [esp]")
		EmitLn("MOV DWORD [eax], ebx")
	else:
		EmitLn("MOV ebx, DWORD [esp]")
		EmitLn("MOV " + GetSizeQualifier(size) + " [eax], " + GetSecondaryRegisterNameBySize(size))

def StackAlloc(n):
	EmitLn("SUB esp, " + str(int(n) * 4))

def StackFree(n):
	EmitLn("ADD esp, " + str(int(n) * 4))

def LoadNumber(v):
	EmitLn("MOV eax, " + str(v))

def LoadLabel(l):
	EmitLn("MOV eax, " + l)

def LoadGlobalVariable(n, size):
	if size == 4:
		EmitLn("MOV eax, DWORD [V_" + n + "]")
	else:
		EmitLn("MOVZX eax, " + GetSizeQualifier(size) + "[V_" + n + "]")

def StoreToGlobalVariable(n, size):
	EmitLn("MOV " + GetSizeQualifier(size) + " [V_" + n + "], " + GetRegisterNameBySize(size))

def LoadLocalVariable(o, size):
	if size == 4:
		EmitLn("MOV eax, DWORD [ebp - (" + str(o) + ")]")
	else:
		EmitLn("MOVZX eax, " + GetSizeQualifier(size) + " [ebp - (" + str(o) + ")]")

def StoreToLocalVariable(o, size):
	EmitLn("MOV " + GetSizeQualifier(size) + " [ebp - (" + str(o) + ")], " + GetRegisterNameBySize(size))

def LoadFunctionPointer(n):
	EmitLn("MOV eax, V_" + n)

def CompareStackTopMain():
	EmitLn("CMP DWORD [esp], eax")

# Control Structures
def BranchTo(l):
	EmitLn("JMP " + l)

def BranchIfFalse(l):
	EmitLn("JNE " + l)

def BranchIfTrue(l):
	EmitLn("JE " + l)

def BranchToAnonymous():
	EmitLn("JMP @f")

def TestNull():
	EmitLn("CMP eax, 0")

def SetIfEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETE al")

def SetIfNotEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETNE al")

def SetIfLessOrEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETBE al")

def SetIfLess():
	EmitLn("MOV eax, 0")
	EmitLn("SETB al")

def SetIfAboveOrEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETAE al")

def SetIfAbove():
	EmitLn("MOV eax, 0")
	EmitLn("SETA al")


# Labels
n_label = 0
def NewLabel():
	global n_label
	
	l = "L" + str(n_label)
	n_label += 1
	return l

def PutIdentifier(l):
	PutLabel("V_" + l)

def PutLabel(l):
	EmitLn(l + ":")

def PutAnonymousLabel():
	PutLabel("@@")

def AllocateGlobalVariable(n, size):
	EmitLnData("V_" + n + " rb " + str(size))
