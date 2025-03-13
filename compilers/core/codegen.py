"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: A set of code generator functions for use by the transpiler
"""

from core.helpers import *

# Utilities
output = ""
output_data = ""

def Emit(s):
	global output
	
	output += s

def EmitLn(s):
	Emit(s + "\n")

def EmitLnData(s):
	global output_data
	
	output_data += s + "\n"

def GetFreestandingOutput():
	global output
	
	output = "use32\n" + "org " + str(0x7c00 + 512 + 512) + "\n" + "JMP V_main\n" +	output
	
	return output + output_data # Return the raw code

def GetWindowsOutput():
	global output, output_data
	
	output = "format PE console\n" + "entry V_main\n" + "section '.text' code readable writeable executable\n" + output
	
	if output_data != "":
		output_data = "section '.data' data readable writeable\n" + output_data
	
	return output + output_data


# Code Generators


# Functions
def OpenStackFrame():
	EmitLn("PUSH ebp")
	EmitLn("MOV ebp, esp")

def CloseStackFrame():
	EmitLn("MOV esp, ebp")
	EmitLn("POP ebp")

def StandardReturn(stack_clean=0):
	EmitLn("RET " + str(stack_clean))

def InterruptReturn():
	EmitLn("IRET")

def PushAll():
	EmitLn("PUSHAD")

def PopAll():
	EmitLn("POPAD")

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

def NotMain():
	EmitLn("NOT eax")

def PrimaryToSecondary():
	EmitLn("MOV ebx, eax")

def SecondaryToPrimary():
	EmitLn("MOV eax, ebx")

def AddMainStackTop():
	EmitLn("ADD DWORD [esp], eax")
	EmitLn("POP eax")

def SubMainStackTop():
	EmitLn("SUB DWORD [esp], eax")
	EmitLn("POP eax")

def MulMainStackTop():
	EmitLn("IMUL DWORD [esp]")
	EmitLn("ADD esp, 4")

def DivMainStackTop():
	EmitLn("POP ebx")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")

def ModMainStackTop():
	EmitLn("POP ebx")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")
	EmitLn("MOV eax, edx")

def ShlMainStackTop():
	EmitLn("MOV cl, al")
	EmitLn("SHL DWORD [esp], cl")
	EmitLn("POP eax")

def ShrMainStackTop():
	EmitLn("MOV cl, al")
	EmitLn("SHR DWORD [esp], cl")
	EmitLn("POP eax")

def AndMainStackTop():
	EmitLn("AND DWORD [esp], eax")
	EmitLn("POP eax")

def OrMainStackTop():
	EmitLn("OR DWORD [esp], eax")
	EmitLn("POP eax")

def XorMainStackTop():
	EmitLn("XOR DWORD [esp], eax")
	EmitLn("POP eax")

def MainToStackTop():
	EmitLn("MOV DWORD [esp], eax")

def DereferenceMain(size):
	# I know we said no logic in the code generators, but this one is needed
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
def Switch(c, l):
	EmitLn("CMP eax, " + str(c))
	EmitLn("JE " + l)

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
