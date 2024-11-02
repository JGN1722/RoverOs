def DeclareGlobalVar(n, val):
	EmitLnData("V_" + n + " db " + val);

def StackAlloc(n):
	if n != 0:
		EmitLn("SUB esp, " + str(n * 4))

def CleanStack(n):
	EmitLn("ADD esp, " + str(n))

def Clear():
	EmitLn("MOV eax, 0")

def SecondaryToPrimary():
	EmitLn("MOV eax, ebx")

def PrimaryToSecondary():
	EmitLn("MOV ebx, eax")

def PopSecondary():
	EmitLn("POP ebx")

def PushSecondary():
	EmitLn("PUSH ebx")

def PushFlags():
	EmitLn("PUSHFD")

def PopFlags():
	EmitLn("POPFD")

def SetTrue():
	EmitLn("MOV eax, 0xFFFFFFFF")

def Negate():
	EmitLn("NEG eax")

def LoadGlobal(n):
	EmitLn("MOV eax, DWORD [V_" + n + "]")

def LoadLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("MOV eax, DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("MOV eax, DWORD [ebp - " + str(o * 4 + 4) + "]")

def AddGlobal(n):
	EmitLn("ADD DWORD [V_" + n + "], eax")

def AddLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("ADD DWORD [ebp + " + str((-o + 1) * 4) + "], eax")
	else:
		EmitLn("ADD DWORD [ebp - " + str(o * 4 + 4) + "], eax")

def SubGlobal(n):
	EmitLn("SUB DWORD [V_" + n + "], eax")

def DecLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("DEC DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("DEC DWORD [ebp - " + str(o * 4 + 4) + "]")

def IncLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("INC DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("INC DWORD [ebp - " + str(o * 4 + 4) + "]")

def SubGlobal(n):
	EmitLn("SUB DWORD [V_" + n + "], eax")

def SubLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("SUB DWORD [ebp + " + str((-o + 1) * 4) + "], eax")
	else:
		EmitLn("SUB DWORD [ebp - " + str(o * 4 + 4) + "], eax")

def MulGlobal(n):
	EmitLn("IMUL DWORD [V_" + n + "], eax")

def MulLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("IMUL DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("IMUL DWORD [ebp - " + str(o * 4 + 4) + "]")

def StoreGlobal(n):
	EmitLn("MOV DWORD [V_" + n + "], eax")

def StoreLocal(o):
	o -= local_param_number
	if o < 0:
		EmitLn("MOV DWORD [ebp + " + str((-o + 1) * 4) + "], eax")
	else:
		EmitLn("MOV DWORD [ebp - " + str(o * 4 + 4) + "], eax")

def DereferenceGlobal(n, size):
	if size == "DWORD":
		register = "eax"
	elif size == "WORD":
		register = "ax"
	elif size == "BYTE":
		register = "al"
	else:
		register = ""
	
	EmitLn("MOV ebx, DWORD [V_" + n + "]")
	EmitLn("MOV " + size + " [ebx], " + register)

def DereferenceLocal(o, size):
	if size == "DWORD":
		register = "eax"
	elif size == "WORD":
		register = "ax"
	elif size == "BYTE":
		register = "al"
	else:
		register = ""
	
	o -= local_param_number
	if o < 0:
		EmitLn("MOV ebx, DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("MOV ebx, DWORD [ebp - " + str(o * 4 + 4) + "]")
	EmitLn("MOV " + size + " [ebx], " + register)

def LoadDereferenceGlobal(n, size):
	if size == "DWORD":
		register = "eax"
	elif size == "WORD":
		register = "ax"
	elif size == "BYTE":
		register = "al"
	else:
		register = ""
	
	EmitLn("MOV ebx, DWORD [V_" + n + "]")
	EmitLn("MOV eax, 0")
	EmitLn("MOV " + register + ", " + size + " [ebx]")

def LoadDereferenceLocal(o, size):
	if size == "DWORD":
		register = "eax"
	elif size == "WORD":
		register = "ax"
	elif size == "BYTE":
		register = "al"
	else:
		register = ""
	
	o -= local_param_number
	if o < 0:
		EmitLn("MOV ebx, DWORD [ebp + " + str((-o + 1) * 4) + "]")
	else:
		EmitLn("MOV ebx, DWORD [ebp - " + str(o * 4 + 4) + "]")
	EmitLn("MOV eax, 0")
	EmitLn("MOV " + register + ", " + size + " [ebx]")

def LoadConst(n):
	EmitLn("MOV eax, " + n)

def LoadPointer(n):
	EmitLn("MOV eax, V_" + n.upper())

def LoadVar(n):
	EmitLn("MOV eax, DWORD [V_" + n.upper() + "]")

def LoadLabel(l):
	EmitLn("MOV eax, " + l)

def Push():
	EmitLn("PUSHD eax")

def Pop():
	EmitLn("POPD eax")

def PushNull():
	EmitLn("PUSHD 0")

def PopAdd():
	EmitLn("ADD eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopSub():
	EmitLn("SUB eax, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("NEG eax")

def PopMul():
	EmitLn("IMUL DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopDiv():
	EmitLn("MOV ebx, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")

def PopModulo():
	EmitLn("MOV ebx, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("XCHG eax, ebx")
	EmitLn("XOR edx, edx")
	EmitLn("IDIV ebx")
	EmitLn("MOV eax, edx")


def PopArShiftLeft():
	EmitLn("MOV cl, al")
	EmitLn("SAL DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopArShiftRight():
	EmitLn("MOV cl, al")
	EmitLn("SAR DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopShiftLeft():
	EmitLn("MOV cl, al")
	EmitLn("SHL DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopShiftRight():
	EmitLn("MOV cl, al")
	EmitLn("SHR DWORD [esp], cl")
	EmitLn("MOV eax, DWORD [esp]")
	EmitLn("ADD esp, 4")


def NotIt():
	EmitLn("NOT eax")

def PopAnd():
	EmitLn("AND eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopOr():
	EmitLn("OR eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopXor():
	EmitLn("XOR eax, DWORD [esp]")
	EmitLn("ADD esp, 4")

def PopCompare():
	EmitLn("MOV ebx, DWORD [esp]")
	EmitLn("ADD esp, 4")
	EmitLn("CMP ebx, eax")

def CompareTopOfStack():
	EmitLn("CMP eax, DWORD [esp]")

def SetEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETE al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def SetNEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETNE al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def SetGreater():
	EmitLn("MOV eax, 0")
	EmitLn("SETG al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def SetLess():
	EmitLn("MOV eax, 0")
	EmitLn("SETB al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def SetLessOrEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETBE al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def SetGreaterOrEqual():
	EmitLn("MOV eax, 0")
	EmitLn("SETGE al")
	EmitLn("IMUL eax, 0xFFFFFFFF")

def XchgTopMain():
	EmitLn("XCHG eax, DWORD [esp]")

def Branch(l):
	EmitLn("JMP " + l)

def BranchFalse(l):
	EmitLn("TEST eax, eax")
	EmitLn("JZ " + l)

def BranchIfFalse(l):
	EmitLn("JNE " + l)

n_label = 0
def NewLabel():
	global n_label
	
	l = "L" + str(n_label)
	n_label += 1
	return l

def PutLabel(l):
	EmitLn(l + ":")

def LoadLabel(l):
	EmitLn("MOV eax, " + l)



def JmpToProc(n):
	EmitLn("CALL V_" + n)

def FunctionHeader():
	EmitLn("PUSH ebp")
	EmitLn("MOV ebp, esp")

def FunctionFooter():
	EmitLn("MOV esp, ebp")
	EmitLn("POP ebp")
	EmitLn("RET")

def Return():
	EmitLn("RET")


def EmitAsIs(s):
	EmitLn(s)