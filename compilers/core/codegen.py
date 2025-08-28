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
	
	return "use32\n" + "org " + str(0x7c00 + 512 + 512) + "\n" + "JMP V_main\n" + output + output_data # Return the raw code

def GetWindowsOutput():
	global output, output_data
	
	output = "format PE console\n" + "entry V_main\n" + "section '.text' code readable writeable executable\n" + output
	
	if output_data != "":
		output_data = "section '.data' data readable writeable\n" + output_data
	
	return output + output_data


# Code Generators


# Functions
def OpenStackFrame():
	EmitLn("PUSH	ebp")
	EmitLn("MOV	ebp, esp")

def CloseStackFrame():
	EmitLn("MOV	esp, ebp")
	EmitLn("POP	ebp")

def StandardReturn(stack_clean=0):
	EmitLn("RET	" + str(stack_clean))

def InterruptReturn():
	EmitLn("IRET")

def PushAll():
	EmitLn("PUSHAD")

def PopAll():
	EmitLn("POPAD")

def CallFunction(n):
	EmitLn("CALL	V_" + n)


# Expressions
def PushMain():
	EmitLn("PUSHD	eax")

def IncrementMain():
	EmitLn("INC	eax")

def DecrementMain():
	EmitLn("DEC	eax")

def NegateMain():
	EmitLn("NEG	eax")

def NotMain():
	EmitLn("NOT	eax")

def LogicalNotMain():
	EmitLn("test	eax, eax")
	EmitLn("setz	al")
	EmitLn("and	eax, 0xff")

def PrimaryToSecondary():
	EmitLn("MOV	ebx, eax")

def SecondaryToPrimary():
	EmitLn("MOV	eax, ebx")

def AddMainStackTop():
	EmitLn("ADD	DWORD [esp], eax")
	EmitLn("POP	eax")

def AddMainVal(n):
	if n == 1:
		EmitLn('INC	eax')
	elif n != 0:
		EmitLn("ADD	eax, " + str(n))

def SubMainStackTop():
	EmitLn("SUB	DWORD [esp], eax")
	EmitLn("POP	eax")

def SubMainVal(n):
	if n == 1:
		EmitLn('DEC	eax')
	elif n != 0:
		EmitLn("SUB	eax, " + str(n))

def MulMainStackTop():
	EmitLn("IMUL	DWORD [esp]")
	EmitLn("ADD	esp, 4")

def MulMainVal(n):
	if n in [2 ** i for i in range(1, 32)]:
		for i in range(1, 32):
			if n == 2 ** i:
				EmitLn('SHL	eax, ' + str(i))
	elif n != 1:
		EmitLn('IMUL	eax, ' + str(n))

def DivMainStackTop():
	EmitLn("POP	ebx")
	EmitLn("XCHG	eax, ebx")
	EmitLn("XOR	edx, edx")
	EmitLn("IDIV	ebx")

def DivMainVal(n):
	if n in [2 ** i for i in range(1, 32)]:
		for i in range(1, 32):
			if n == 2 ** i:
				EmitLn('SHR	eax, ' + str(i))
	elif n != 1:
		EmitLn("MOV	ebx, " + str(n))
		EmitLn("XOR	edx, edx")
		EmitLn("IDIV	ebx")

def DivValMain(n):
	if n != 0:
		EmitLn("MOV	ebx, " + str(n))
		EmitLn("XOR	edx, edx")
		EmitLn("IDIV	ebx, eax")
	else:
		EmitLn("MOV	eax, 0")

def ModMainStackTop():
	EmitLn("POP	ebx")
	EmitLn("XCHG	eax, ebx")
	EmitLn("XOR	edx, edx")
	EmitLn("IDIV	ebx")
	EmitLn("MOV	eax, edx")

def ModMainVal(n):
	if n in [2 ** i for i in range(1, 32)]:
		for i in range(1, 32):
			if n == 2 ** i:
				EmitLn('AND	eax, ' + str(i))
	else:
		EmitLn("MOV	ebx, " + str(n))
		EmitLn("XOR	edx, edx")
		EmitLn("IDIV	ebx")
		EmitLn("MOV	eax, edx")

def ShlMainStackTop():
	EmitLn("MOV	cl, al")
	EmitLn("SHL	DWORD [esp], cl")
	EmitLn("POP	eax")

def ShlMainVal(n):
	if n != 0:
		EmitLn("SHL	eax, " + str(n))

def ShlValMain(n):
	if n != 0:
		EmitLn("MOV	cl, al")
		EmitLn("MOV	eax, " + str(n))
		EmitLn("SHL	eax, cl")

def ShrMainStackTop():
	EmitLn("MOV	cl, al")
	EmitLn("SHR	DWORD [esp], cl")
	EmitLn("POP	eax")

def ShrMainVal(n):
	if n != 0:
		EmitLn("SHR	eax, " + str(n))

def ShrValMain(n):
	if n != 0:
		EmitLn("MOV	cl, al")
		EmitLn("MOV	eax, " + str(n))
		EmitLn("SHR	eax, cl")

def AndMainStackTop():
	EmitLn("AND	DWORD [esp], eax")
	EmitLn("POP	eax")

def OrMainStackTop():
	EmitLn("OR	DWORD [esp], eax")
	EmitLn("POP	eax")

def XorMainStackTop():
	EmitLn("XOR	DWORD [esp], eax")
	EmitLn("POP	eax")

def MainToStackTop():
	EmitLn("MOV	DWORD [esp], eax")

def CallMain():
	EmitLn("CALL	eax")

def DereferenceMain(size):
	if size == 4:
		EmitLn("MOV	eax, DWORD [eax]")
	else:
		EmitLn("MOVZX	eax, " + GetSizeQualifier(size) + " [eax]")

def StoreDereferenceMain(size):
	if size == 4:
		EmitLn("POP	ebx") # Previously MOV	ebx, DWORD [esp], idk it felt wrong
		EmitLn("MOV	DWORD [eax], ebx")
	else:
		EmitLn("POP	ebx")
		EmitLn("MOV	" + GetSizeQualifier(size) + " [eax], " + GetSecondaryRegisterNameBySize(size))

def StackAlloc(n):
	n = int(n)
	if n != 0:
		EmitLn("SUB	esp, " + str((n // 4) * 4 + 4 if n % 4 != 0 else n))

def StackFree(n):
	if int(n) != 0:
		EmitLn("ADD	esp, " + str(int(n) * 4))

def LoadNumber(v):
	EmitLn("MOV	eax, " + str(v))

def LoadLabel(l):
	EmitLn("MOV	eax, " + l)

def LoadGlobalVariable(n, size):
	if size == 4:
		EmitLn("MOV	eax, DWORD [V_" + n + "]")
	else:
		EmitLn("MOVZX	eax, " + GetSizeQualifier(size) + "[V_" + n + "]")

def LoadGlobalIdentifierAddress(n):
	EmitLn("MOV	eax, V_" + n)

def StoreToGlobalVariable(n, size):
	EmitLn("MOV	" + GetSizeQualifier(size) + " [V_" + n + "], " + GetRegisterNameBySize(size))

def LoadLocalVariable(o, size):
	if size == 4:
		EmitLn("MOV	eax, DWORD [ebp - (" + str(o) + ")]")
	else:
		EmitLn("MOVZX	eax, " + GetSizeQualifier(size) + " [ebp - (" + str(o) + ")]")

def LoadLocalIdentifierAddress(o):
	EmitLn("MOV	eax, ebp")
	EmitLn("SUB	eax, " + str(o))

def StoreToLocalVariable(o, size):
	EmitLn("MOV	" + GetSizeQualifier(size) + " [ebp - (" + str(o) + ")], " + GetRegisterNameBySize(size))

def CompareStackTopMain():
	EmitLn("CMP	DWORD [esp], eax")

def CompareMainVal(n):
	EmitLn("CMP	eax, " + str(n))

def CompareValMain(n):
	EmitLn("CMP	" + str(n) + ", eax")

# Control Structures
def Switch(c, l):
	EmitLn("CMP	eax, " + str(c))
	EmitLn("JE	" + l)

def BranchTo(l):
	EmitLn("JMP	" + l)

def BranchIfFalse(l):
	EmitLn("JNE	" + l)

def BranchIfTrue(l):
	EmitLn("JE	" + l)

def BranchIfEqual(l):
	EmitLn("JE	" + l)

def BranchIfNotEqual(l):
	EmitLn("JNE	" + l)

def BranchIfLessOrEqual(l):
	EmitLn("JBE	" + l)

def BranchIfLess(l):
	EmitLn("JB	" + l)

def BranchIfAboveOrEqual(l):
	EmitLn("JAE	" + l)

def BranchIfAbove(l):
	EmitLn("JA	" + l)

def BranchToAnonymous():
	EmitLn("JMP	@f")

def TestNull():
	EmitLn("CMP	eax, 0")

def SetIfEqual():
	EmitLn("MOV	eax, 0")
	EmitLn("SETE	al")

def SetIfNotEqual():
	EmitLn("MOV	eax, 0")
	EmitLn("SETNE	al")

def SetIfLessOrEqual():
	EmitLn("MOV	eax, 0")
	EmitLn("SETBE	al")

def SetIfLess():
	EmitLn("MOV	eax, 0")
	EmitLn("SETB	al")

def SetIfAboveOrEqual():
	EmitLn("MOV	eax, 0")
	EmitLn("SETAE	al")

def SetIfAbove():
	EmitLn("MOV	eax, 0")
	EmitLn("SETA	al")


# Labels
n_label = 0
def NewLabel():
	global n_label
	
	l = "L" + str(n_label)
	n_label += 1
	return l

def PutIdentifier(l):
	PutLabel("V_" + l)

def AlignData(n):
	EmitLnData('align ' + str(n))

def PutLabel(l):
	EmitLn(l + ":")

def PutAnonymousLabel():
	PutLabel("@@")

def AllocateGlobalVariable(n, size):
	EmitLnData("V_" + n + " rb " + str(size))

def AllocateInitGlobalVariable(n, size, val):
	if size == 1:	d = ' db '
	elif size == 2:	d = ' dw '
	elif size == 4:	d = ' dd '
	EmitLnData("V_" + n + d + str(val))
