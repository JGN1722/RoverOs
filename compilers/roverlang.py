"""
RoverLang Compiler
Written for RoverOs
Author: JGN1722 (Github)
"""

import subprocess
import sys
import os

script_directory = os.path.dirname(os.path.abspath(__file__))

# Import the needed files
from symtable import *
from helpers import *
from codegen import *
import commandline
import tokenizer
import preproc
import parser

tokenizer.script_directory = script_directory
commandline.script_directory = script_directory

debug_mode = 0

def compile():
	global source_file, output_file
	
	output, output_data = GetOutput()
	
	output += output_data
	
	with open(script_directory + "\\output.asm", "w") as file:
		file.write(output)
	
	subprocess.run([script_directory + "\\fasm.exe",script_directory + "\\output.asm",output_file])

# Error functions
def abort(s):
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit()

def Warning(s):
	print("Warning: " + s, "(file", file_name, "line", line_number, "character", character_number, ")")

def Undefined(n):
	if IsKeyword(n):
		abort("keyword is misplaced ( " + n + " )")
	abort("undefined name ( " + n + " )")

def Expected(s):
	abort("Expected " + s)

# Output functions

file_name = ""
line_number = 0
character_number = 0
source_file = ""
output_file = ""

def dbg():
	print("token: ", token)
	print("value: ", value)

# Parsing unit
def Next():
	global token_stream, streampos, token, value, file_name, line_number, character_number
	
	streampos += 1
	
	new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def Previous():
	global token_stream, streampos, token, value, file_name, file_number, character_number
	
	streampos -= 1
	
	new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def MatchString(t):
	if value == t:
		Next()
	else:
		Expected(t)

#_________________________________________________________________________________________
# Main code
def program():
	while token != "\0":
		if token == "x" and value == "GLOBAL":
			GlobalDeclaration()
		elif token == "x" and value == "STRUCT":
			StructDeclaration()
		elif token == "x" and IsType(value):
			Function()
		else:
			Expected("function declaration")

def GlobalDeclaration():
	MatchString("GLOBAL")
	if not IsType(value):
		Expected("type")
	Next()
	add_global_symbol(value)
	if token == "=":
		MatchString("=");
		if not token == "0":
			Expected("Literal numeric constant")
		v = value
	else:
		v = "0"
	DeclareGlobalVar(value, v)
	Next()
	
	if token == ",":
		MatchString(",");
		if not IsType(value):
			Expected("type")
		Next()
		add_global_symbol(value)
		if token == "=":
			MatchString("=");
			if not token == "0":
				Expected("Literal numeric constant")
			v = value
		else:
			v = 0
		DeclareGlobalVar(value, v)
		Next()
	
	MatchString(";")

#_________________________________________________________________________________________
# Structures and arrays
def StructDeclaration():
	MatchString("STRUCT")
	name = value
	add_struct(name)
	Next()
	MatchString("{")
	while IsType(value) or IsSize(value):
		t = value
		Next()
		n = value
		Next()
		add_member(name, t, n)
		while value == ",":
			MatchString(",")
			n = value
			Next()
			add_member(name, t, n)
		MatchString(";")
	MatchString("}")

#_________________________________________________________________________________________
# Functions and blocks
current_function = ""
def Function():
	global current_function, local_param_number
	
	if not IsType(value):
		Expected("Type instead of " + value)
	function_type = value
	Next()
	if token != "x":
		Expected("Identifier")
	function_name = value
	current_function = function_name
	add_global_symbol(function_name, IDENTIFIER_FUNCTION, function_type, 0, 0)
	Next()
	MatchString("(")
	clear_local_symbol_table()
	function_arg_count = ArgList()
	local_param_number = function_arg_count
	MatchString(")")
	PutLabel("V_" + function_name)
	FunctionHeader()
	Block("")
	PutLabel("RET_" + function_name)
	FunctionFooter()

def ArgList():
	arg_num = 0
	
	if not IsType(value):
		return 0
	arg_type = value
	Next()
	arg_name = value
	Next()
	arg_num += 1
	add_local_symbol(arg_name, IDENTIFIER_VARIABLE, arg_type, 0, 0)
	
	while token == ",":
		MatchString(",")
		if not IsType(value):
			Expected("type instead of " + value)
		arg_type = value
		Next()
		arg_name = value
		Next()
		
		arg_num += 1
		add_local_symbol(arg_name, IDENTIFIER_VARIABLE, arg_type, 0, 0)
	
	return arg_num

def LocalDeclarations():
	var_num = 0
	
	while IsType(value) or value == "STRUCT":
		if value == "STRUCT":
			Next()
		variable_type = value
		Next()
		variable_name = value
		Next()
		
		var_num += 1
		add_local_symbol(variable_name, IDENTIFIER_VARIABLE, variable_type, 0, 0)
		while token == ",":
			Next()
			variable_name = value
			Next()
			
			var_num += 1
			add_local_symbol(variable_name, IDENTIFIER_VARIABLE, variable_type, 0, 0)
		MatchString(";")
	
	return var_num

def Block(L):
	global local_symbol_table
	
	MatchString("{")
	old_local_identifier_number = len(local_symbol_table)
	block_loc_vars_count = LocalDeclarations()
	StackAlloc(block_loc_vars_count)
	
	while not token == "}":
		if token == "*":
			StarDereferencing()
		elif IsSize(value):
			Dereferencing()
		elif value == "IF":
			DoIf(L)
		elif value == "WHILE":
			DoWhile()
		elif value == "FOR":
			DoFor()
		elif value == "DO":
			DoLoop()
		elif value == "REPEAT":
			DoRepeat()
		elif value == "BREAK":
			DoBreak(L)
		elif value == "RETURN":
			DoReturn()
		elif value == "{":
			Block(L)
		elif value == "ASM":
			InlineAssembly()
		elif token == ".":
			DoPass()
		elif token == "s":
			Next()
		else:
			if get_symbol_type(value) == IDENTIFIER_VARIABLE:
				AssignStatement()
			elif get_symbol_type(value) == IDENTIFIER_FUNCTION:
				CallProcStatement()
			else:
				n = value
				Next()
				if token == "[":
					ArrayDereferencing()
				if not token == "(":
					Undefined(n)
				Warning("call to undefined function (" + n + ")")
				CallProc(n)
				MatchString(";")
	
	local_symbol_table = local_symbol_table[:old_local_identifier_number]
	MatchString("}")

def DoPass():
	MatchString(".")
	MatchString(".")
	MatchString(".")

def CallProcStatement():
	name = value
	Next()
	CallProc(name)
	MatchString(";")

def CallProc(name):
	MatchString("(")
	param_number = ParamList()
	MatchString(")")
	JmpToProc(name)
	if param_number != 0:
		CleanStack(param_number)

def ParamList():
	if value == ")":
		return 0
	BoolExpression()
	Push()
	param_number = 4
	while token == ",":
		Next()
		BoolExpression()
		Push()
		param_number += 4
	return param_number

def AssignStatement():
	Assignement()
	MatchString(";")

def Assignement():
	if not is_local_symbol(value) and not is_global_symbol(value):
		Undefined(value)
	n = value
	Next()
	
	if token == ".":
		StructDereferencing(n)
		return
	
	if token == "=":
		MatchString("=")
		BoolExpression()
		if is_global_symbol(n):
			StoreGlobal(n)
		else:
			StoreLocal(get_local_symbol_offset(n), local_param_number)
	
	elif token == "-":
		MatchString("-")
		
		if token == "-":
			MatchString("-")
			if is_global_symbol(n):
				DecGlobal(n)
			else:
				DecLocal(get_local_symbol_offset(n), local_param_number)
		else:
			MatchString("=")
			BoolExpression()
			if is_global_symbol(n):
				SubGlobal(n)
			else:
				SubLocal(get_local_symbol_offset(n), local_param_number)
	elif token == "+":
		MatchString("+")
		
		if token == "+":
			MatchString("+")
			if is_global_symbol(n):
				IncGlobal(n)
			else:
				IncLocal(get_local_symbol_offset(n), local_param_number)
		else:
			MatchString("=")
			BoolExpression()
			if is_global_symbol(n):
				AddGlobal(n)
			else:
				AddLocal(get_local_symbol_offset(n), local_param_number)
	elif token == "*":
		MatchString("*")
		MatchString("=")
		BoolExpression()
		if is_global_symbol(n):
			MulGlobal(n)
		else:
			MulLocal(get_local_symbol_offset(n), local_param_number)
	
	else:
		Expected("=")

def InlineAssembly():
	MatchString("ASM")
	MatchString("(")
	if not token == "s":
		Expected("string literal")
	EmitAsIs(value)
	Next()
	MatchString(")")
	MatchString(";")

def DoReturn():
	global current_function
	
	MatchString("RETURN")
	BoolExpression()
	MatchString(";")
	Branch("RET_" + current_function)

def StarDereferencing(size="DWORD"):
	MatchString("*")
	n = value
	Next()
	MatchString("=")
	BoolExpression()
	if is_global_symbol(n):
		DereferenceGlobal(n, size)
	else:
		DereferenceLocal(get_local_symbol_offset(n), size, local_param_number)
	MatchString(";")

def ArrayDereferencing(size="DWORD"):
	n = value
	Next()
	MatchString("[")
	BoolExpression()
	MatchString("]")
	PrimaryToSecondary()
	LoadConst(str(SizeOf(size)))
	MulPrimarySecondary()
	PrimaryToSecondary()
	if is_global_symbol(n):
		LoadGlobal(n)
	else:
		LoadLocal(get_local_symbol_offset(n))
	AddPrimarySecondary()
	Push()
	MatchString("=")
	BoolExpression()
	PopSecondary()
	StoreDereferenceSecondary(size)
	MatchString(";")

def StructDereferencing(n):
	MatchString(".")
	attr = value
	Next()
	MatchString("=")
	BoolExpression()
	PrimaryToSecondary()
	if is_global_symbol(n):
		LoadGlobal(n)
	else:
		LoadLocal(get_local_symbol_offset(n))
	AddToPrimary(str(get_member_info(get_data_type(n), attr)[2]))
	XchgPrimarySecondary()
	StoreDereferenceSecondary(get_member_info(get_data_type(n), attr)[1])

def Dereferencing():
	size = value
	Next()
	if token != "*":
		ArrayDereferencing(size)
	else:
		StarDereferencing(size)

def LoadPointerContent(n,size):
	if is_global_symbol(n):
		LoadDereferenceGlobal(n,size)
	else:
		LoadDereferenceLocal(get_local_symbol_offset(n),size,local_param_number)
		

#_________________________________________________________________________________________
# Control structures
def DoIf(L):
	MatchString("IF")
	L1 = NewLabel()
	BoolExpression()
	L2 = NewLabel()
	BranchFalse(L2)
	Block(L)
	Branch(L1)
	PutLabel(L2)
	while value == "ELSEIF":
		MatchString("ELSEIF")
		BoolExpression()
		L2 = NewLabel()
		BranchFalse(L2)
		Block(L)
		Branch(L1)
		PutLabel(L2)
	if value == "ELSE":
		MatchString("ELSE")
		Block(L)
		Branch(L1)
	PutLabel(L1)

def DoWhile():
	MatchString("WHILE")
	L1 = NewLabel()
	L2 = NewLabel()
	PutLabel(L1)
	BoolExpression()
	BranchFalse(L2)
	Block(L2)
	Branch(L1)
	PutLabel(L2)

def DoLoop():
	MatchString("DO")
	L1 = NewLabel()
	L2 = NewLabel()
	PutLabel(L1)
	Block(L2)
	Branch(L1)
	PutLabel(L2)

def DoRepeat():
	MatchString("REPEAT")
	L1 = NewLabel()
	L2 = NewLabel()
	PutLabel(L1)
	Block(L2)
	MatchString("UNTIL")
	BoolExpression()
	MatchString(";")
	BranchFalse(L1)
	PutLabel(L2)

def DoBreak(L):
	MatchString("BREAK")
	MatchString(";")
	Branch(L)

def DoFor():
	MatchString("FOR")
	MatchString("(")
	
	# Initialision
	if not IsType(value):
		Expected("counter variable declaration")
	counter_type = value
	Next()
	counter_name = value
	add_local_symbol(counter_name, IDENTIFIER_VARIABLE, counter_type, 0, 0)
	Next()
	MatchString("=")
	BoolExpression()
	Push()
	MatchString(";")
	
	# Condition
	L1 = NewLabel()
	L2 = NewLabel()
	PutLabel(L1)
	BoolExpression()
	BranchFalse(L2)
	MatchString(";")
	
	# Update
	Assignement()
	
	MatchString(")")
	
	Block(L2)
	Branch(L1)
	PutLabel(L2)
	
	remove_local_symbol(counter_name)

#_________________________________________________________________________________________
# Expressions
def BitWiseFactor():
	if token == "(":
		Next()
		BoolExpression()
		MatchString(")")
	elif token == "@":
		MatchString("@")
		LoadPointer(value)
		Next()
	elif token == "x":
		n = value
		Next()
		if is_global_symbol(n) or is_local_symbol(n):
			if get_symbol_type(n) == IDENTIFIER_VARIABLE:
				if get_data_type(n) != "INT":
					t = get_data_type(n)
					if is_struct(t):
						MatchString(".")
						attr = value
						Next()
						if is_global_symbol(n):
							LoadGlobal(n)
						else:
							LoadLocal(get_local_symbol_offset(n), local_param_number)
						AddToPrimary(str(get_member_info(t, attr)[2]))
						DereferencePrimary(get_member_info(t, attr)[1])
					else:
						abort("Variable " + n + " is not a math factor")
				elif is_global_symbol(n):
					LoadGlobal(n)
				else:
					LoadLocal(get_local_symbol_offset(n), local_param_number)
			elif get_symbol_type(n) == IDENTIFIER_FUNCTION:
				CallProc(n)
			else:
				abort("unexpected identifier type")
		elif IsSize(n):
			size = n
			if token == "*":
				MatchString("*")
				n = value
				Next()
				LoadPointerContent(n,size)
			else:
				n = value
				Next()
				MatchString("[")
				BoolExpression()
				MatchString("]")
				PrimaryToSecondary()
				LoadConst(str(SizeOf(size)))
				MulPrimarySecondary()
				PrimaryToSecondary()
				if is_global_symbol(n):
					LoadGlobal(n)
				else:
					LoadLocal(get_local_symbol_offset(n))
				AddPrimarySecondary()
				DereferencePrimary(size)
		else:
			Undefined(n)
	elif token == "*":
		size = "DWORD"
		MatchString("*")
		n = value
		Next()
		LoadPointerContent(n,size)
	elif token == "#":
		MatchString("#")
		LoadConst(value)
		Next()
	elif token == "0":
		LoadConst(value)
		Next()
	elif token == "s":
		L = NewLabel()
		EmitLnData(FormatString(L, value))
		LoadLabel(L)
		Next()
	else:
		Expected("Math Factor")

def ShiftLeft():
	MatchString("SHL")
	BitWiseFactor()
	PopShiftLeft()

def ShiftRight():
	MatchString("SHR")
	BitWiseFactor()
	PopShiftRight()

def ShifArtLeft():
	MatchString("SAL")
	BitWiseFactor()
	PopArShiftLeft()

def ShiftArRight():
	MatchString("SAR")
	BitWiseFactor()
	PopArShiftRight()

def Factor():
	BitWiseFactor()
	while IsBitWiseOp(value):
		Push()
		if value == "SHL":
			ShiftLeft()
		elif value == "SHR":
			ShiftRight()
		elif value == "SAL":
			ShiftArLeft()
		elif value == "SAR":
			ShiftArRight()

def NegFactor():
	MatchString("-")
	if token == "0":
		LoadConst("-" + Value)
		Next()
	else:
		Factor()
		Negate()

def Multiply():
	Next()
	if token == "-":
		NegFactor()
	else:
		Factor()
	PopMul()

def Divide():
	Next()
	if token == "-":
		NegFactor
	else:
		Factor()
	PopDiv()

def Modulo():
	Next()
	if token == "-":
		NegFactor()
	else:
		Factor()
	PopModulo()

def Term():
	if token == "-":
		NegFactor()
	else:
		Factor()
	while IsMulop(token):
		Push()
		if token == "*":
			Multiply()
		elif token == "/":
			Divide()
		elif token == "%":
			Modulo()

def Add():
	Next()
	Term()
	PopAdd()

def Subtract():
	Next()
	Term()
	PopSub()

def Expression():
	if IsAddop(token):
		Clear()
	else:
		Term()
	while IsAddop(token):
		Push()
		if token == "+":
			Add()
		elif token == "-":
			Subtract()

#_________________________________________________________________________________________
# Boolean expressions
def CompareExpression():
	Expression()
	PopCompare()

def NextExpression():
	Next()
	CompareExpression()

def Equal():
	NextExpression()
	SetEqual()

def LessOrEqual():
	NextExpression()
	SetLessOrEqual()

def NotEqual():
	NextExpression()
	SetNEqual()

def Less():
	Next()
	if token == "=" :
		LessOrEqual()
	elif token == ">" :
		NotEqual()
	else:
		CompareExpression()
		SetLess()

def Greater():
	Next()
	if token == "=":
		NextExpression()
		SetGreaterOrEqual()
	else:
		CompareExpression()
		SetGreater()

def Relation():
	Expression()
	if IsRelop(token):
		Push()
		if token == "=":
			Equal()
		elif token == "<":
			Less()
		elif token == ">":
			Greater()
		elif token == "!":
			MatchString("!")
			if token == "=":
				NotEqual()
			else:
				Expected("=")

def NotFactor():
	if token == "!" or value == "NOT":
		Next()
		Relation()
		NotIt()
	else:
		Relation()

def BoolTerm():
	NotFactor()
	while token == "&" or value == "AND":
		Push()
		Next()
		NotFactor()
		PopAnd()

def BoolOr():
	Next()
	BoolTerm()
	PopOr()

def BoolXor():
	Next()
	BoolTerm()
	PopXor()

def BoolExpression():
	BoolTerm()
	while IsOrop(value):
		Push()
		if value == "OR" or value == "|":
			BoolOr()
		elif value == "XOR" or value == "~":
			BoolXor()

# Main code
if __name__ == "__main__":
	# Check the command line arguments and options
	source_file, output_file = commandline.ParseCommandLine()
	
	# Read the source
	if source_file == "":
		abort("source file not specified")
	source_text = ReadSourceText(source_file, script_directory)
	
	file_name = source_file
	
	# Tokenize the program
	tokenizer.file_name = file_name
	tokenizer.source_text = source_text
	token_stream = tokenizer.Tokenize(is_main_file=True)
	
	# Extend the macros, include the files and such
	preproc.token_stream = token_stream
	preproc.Preprocess()
	
	# Produce the AST
	AST = parser.ProduceAST()
	
	# Begin compiling
	streampos = -1
	Next()
	program()
	compile()
