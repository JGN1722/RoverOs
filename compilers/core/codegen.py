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

def MainToStackTop():
	EmitLn("MOV DWORD [esp], eax")

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
