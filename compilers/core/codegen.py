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
	EmitLn("SUB eax, DWORD [esp]")
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

def DereferenceMain():
	EmitLn("MOV eax, DWORD [eax]")

def StackAlloc(n):
	EmitLn("SUB esp, " + str(n))

def LoadNumber(v):
	EmitLn("MOV eax, " + str(v))

def LoadLabel(l):
	EmitLn("MOV eax, " + l)

def LoadGlobalVariable(n, size):
	EmitLn("MOVZX eax, " + GetSizeQualifier(size) + "[V_" + n + "]")

def LoadLocalVariable(o):
	...

def LoadFunctionPointer(n):
	EmitLn("MOV eax, V_" + n)

def CompareMainStackTop():
	EmitLn("CMP eax, DWORD [esp]")

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
