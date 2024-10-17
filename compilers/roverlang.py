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
exec(open(script_directory + "\\" + "codegen.py").read())
exec(open(script_directory + "\\" + "tokenizer.py").read())
exec(open(script_directory + "\\" + "helpers.py").read())
exec(open(script_directory + "\\" + "symtable.py").read())

"""
commmand line options:
-h / --help : help message
"""

if len(sys.argv) >= 2:
	if sys.argv[1] == "-h" or sys.argv[1] == "--help":
		print("RoverLang Compiler\n" +
		      "Written for RoverOs\n" + 
		      "Author: JGN1722 (Github)\n\n" +
		      "Usage: roverlang.py [-h | --help] | [filename]")
		sys.exit()

def convert_to_bin(file_path):
	# Split the file path into base and extension
	base, ext = os.path.splitext(file_path)
	
	# If there's no extension, just append .bin
	if ext == '':
		return file_path + '.bin'
		
	# If an extension exists, replace it with .bin
	return base + '.bin'

def compile():
	global source_file, output, output_data
	
	output += output_data
	
	if len(sys.argv) >= 3:
		output_file = sys.argv[2]
	else:
		output_file = convert_to_bin(abs_source_file)
	
	with open(script_directory + "\\output.asm", "w") as file:
		file.write(output)
	
	subprocess.run([script_directory + "\\fasm.exe",script_directory + "\\output.asm",output_file])

# Error functions
def abort(s):
	print("Error: " + s, file=sys.stderr)
	sys.exit()

def Undefined(n):
	if IsKeyword(n):
		abort("keyword is misplaced ( " + n + " )")
	abort("undefined name ( " + n + " )")

# Compiling unit

# Open the source file and set global variables
# Check if it exists. If not, print an error message

if len(sys.argv) >= 2:
	source_file = sys.argv[1]
else:
	abort("source file not specified")

if source_file == "":
	abort("source file not specified")

if source_file[:3][1:] == ":\\":
	abs_source_file = source_file
else:
	abs_source_file = script_directory + "\\" + source_file

if not os.path.isfile(abs_source_file):
	abort("source file not found (" + abs_source_file + ")")

file = open(abs_source_file)
source_text = file.read()
file.close()

lookahead = source_text[0]
streampos = 1
token = ""
value = ""

output = ""
output += "use32\n"
output += "org " + str(0x7e00 + 512) + "\n"
output += "JMP V_MAIN\n" # Immediately add the entry point code

output_data = ""

def dbg():
	print("token: ", token)
	print("value: ", value)
	print("streampos: ", streampos)

def Emit(s):
	global output
	
	output += s

def EmitLn(s):
	Emit(s + "\n")

def EmitLnData(s):
	global output_data
	
	output_data += s + "\n"

# Parsing unit

#_________________________________________________________________________________________
# Main code
def program():
	while token != "\0":
		if value == "INCLUDE":
			IncludeFile()
		elif IsType(value):
			Function()
		elif token == "#":
			PrettyConstantDeclaration()
		else:
			n = value
			Next()
			if not token == "=":
				Expected("function declaration")
			ConstantDeclaration(n)

def IncludeFile():
	global source_text, streampos, lookahead
	
	MatchString("INCLUDE")
	if not token == "s":
		Expected("name of file to include")
	if value == "":
		abort("source file not specified")
	
	if value[:3][1:] == ":\\":
		new_source_file = value
	else:
		new_source_file = os.path.dirname(abs_source_file) + "\\" + value
	
	if not os.path.isfile(new_source_file):
		abort("source file not found (" + new_source_file + ")")
	
	text_to_add = open(new_source_file).read()
	source_text = source_text[:(streampos-1)] + text_to_add + source_text[(streampos-1):]
	# Reupdate lookahead, because the source text changed
	lookahead = source_text[streampos-1]
	
	Next()

def PrettyConstantDeclaration():
	MatchString("#")
	n = value
	Next()
	ConstantDeclaration(n)

def ConstantDeclaration(n):
	MatchString("=")
	Emit(n + " = ")
	
	if not token == "0":
		Expected("litteral constant")
	
	Emit(value)
	Next()
	
	while token == "+" or token == "-" or token == "*":
		Emit(token)
		Next()
		if not token == "0":
			Expected("litteral constant")
		Emit(value)
		Next()
	
	Emit("\n")

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
	
	while IsType(value):
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
			if not is_global_symbol(value) and not is_local_symbol(value):
				Undefined(value)
			if get_symbol_type(value) == IDENTIFIER_VARIABLE:
				AssignStatement()
			elif get_symbol_type(value) == IDENTIFIER_FUNCTION:
				CallProcStatement()
			else:
				abort("unrecognized identifier")
	
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
	
	if token == "=":
		MatchString("=")
		BoolExpression()
		if is_global_symbol(n):
			StoreGlobal(n)
		else:
			StoreLocal(get_local_symbol_offset(n))
	
	elif token == "-":
		MatchString("-")
		
		if token == "-":
			MatchString("-")
			if is_global_symbol(n):
				DecGlobal(n)
			else:
				DecLocal(get_local_symbol_offset(n))
		else:
			MatchString("=")
			BoolExpression()
			if is_global_symbol(n):
				SubGlobal(n)
			else:
				SubLocal(get_local_symbol_offset(n))
	elif token == "+":
		MatchString("+")
		
		if token == "+":
			MatchString("+")
			if is_global_symbol(n):
				IncGlobal(n)
			else:
				IncLocal(get_local_symbol_offset(n))
		else:
			MatchString("=")
			BoolExpression()
			if is_global_symbol(n):
				AddGlobal(n)
			else:
				AddLocal(get_local_symbol_offset(n))
	elif token == "*":
		MatchString("*")
		MatchString("=")
		BoolExpression()
		if is_global_symbol(n):
			MulGlobal(n)
		else:
			MulLocal(get_local_symbol_offset(n))

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
	MatchString("(")
	BoolExpression()
	MatchString(")")
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
		DereferenceLocal(get_local_symbol_offset(n), size)
	MatchString(";")

def Dereferencing():
	size = value
	Next()
	StarDereferencing(size)

def LoadPointerContent(n,size):
	if is_global_symbol(n):
		LoadDereferenceGlobal(n,size)
	else:
		LoadDereferenceLocal(get_local_symbol_offset(n),size)
		

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
		if GetIdentType(value) != "":
			LoadPointer(value)
			Next()
		else:
			Undefined(value)
	elif token == "x":
		n = value
		Next()
		if is_global_symbol(n) or is_local_symbol(n):
			if get_symbol_type(n) == IDENTIFIER_VARIABLE:
				if get_data_type(n) != "INT":
					abort("Type mismatch, variable " + n + " is not of type INT")
				if is_global_symbol(n):
					LoadGlobal(n)
				else:
					LoadLocal(get_local_symbol_offset(n))
			elif get_symbol_type(n) == IDENTIFIER_FUNCTION:
				CallProc(n)
			else:
				abort("unexpected identifier type")
		elif IsSize(n):
			size = n
			MatchString("*")
			n = value
			Next()
			LoadPointerContent(n,size)
	#	if GetIdentType(n) == "procedure":
	#		if GetDataType(n) != "INT":
	#			Abort("Type mismatch, procedure " + n + " is not of type INT")
	#		CallProc(n)
	#	ElseIf Constants.Exists(n) Then
	#		If Constants.Item(n)(0) <> "INT" Then Abort("Type mismatch, constant " & n & " is not of type INT")
	#		LoadConstant(n)
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
	Next()
	program()
	compile()