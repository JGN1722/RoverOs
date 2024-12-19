import sys

from core.helpers import *
import core.symboltable as st
import core.codegen as cg

AST = None

# Error functions
def abort(s):
	# I'm still yet to find how to use file_name, line_number and character_number here
	#print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	# For now, just print it raw
	print("Error: " + s, file=sys.stderr)
	sys.exit()

def Expected(s):
	abort("Expected " + s)

def Undefined(n):
	abort("Undefined variable (" + n + ")")


def transpile():
	
	# Register the global identifiers first
	for node in AST.children:
		if node.type == "Function":
			st.AddFunction(node.value["name"], node.value["type"], node.children[0].children)
		elif node.type == "StructDecl":
			st.AddStruct(node.value, node.children)
		elif node.type == "GlobalDecl":
			st.AddVariable(node.value["name"], node.value["type"], True)
			cg.AllocateGlobalVariable(node.value["name"], st.SizeOf(node.value["type"].datatype))
	
	# Delete the unneeded data from the tree to free memory
	i = 0
	while i < len(AST.children):
		if AST.children[i].type == "Function":
			i += 1
		else:
			del AST.children[i] # Delete the structs and the global variables
	
	# Put Main at the top
	main_func = None
	for node in AST.children:
		if node.value["name"] == "MAIN":
			main_func = node
	
	if main_func == None:
		abort("No main function")
	if st.GetFunctionArgCount("MAIN") != 0:
		abort("The main function should take no arguments")
	if st.GetFunctionType("MAIN") != Type_("INT", pointer_level=0):
		abort("The main function should only return an int")
	
	# Compile main function
	CompileFunction(main_func)
	
	# Delete it from the stream so it's not compiled two times
	for i in range(len(AST.children)):
		if AST.children[i].value["name"] == "MAIN":
			del AST.children[i]
			break
	
	for node in AST.children:
		# Compile the function we found
		CompileFunction(node)
	
	print(cg.GetOutput())
	return cg.GetOutput()

def CompileFunction(node):
	func_name = node.value["name"]
	
	cg.PutIdentifier(func_name)
	cg.FunctionHeader()
	
	for arg in node.children[0].children:
		st.AddVariable(arg["name"], arg["type"])
	
	CompileBlock(node.children[1])
	
	cg.PutAnonymousLabel()
	
	cg.FunctionFooter()
	st.DeleteLocalVariables()

def CompileBlock(node):
	for statement in node.children:
		if statement.type == "LocDecl":
			CompileLocDecl(statement)
		elif statement.value == "ASM":
			CompileAsm(statement)
		elif statement.value == "IF":
			CompileIf(statement)
		elif statement.value == "WHILE":
			CompileWhile(statement)
		elif statement.value == "RETURN":
			CompileReturn(statement)
		elif statement.value == "Block":
			CompileBlock(statement)
		elif statement.value == "BREAK":
			CompileBreak(statement)
		else:
			CompileExpression(statement)

def CompileAsm(node):
	cg.EmitLn(node.children[0].value)

def CompileIf(node):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	CompileExpression(node.children[0])
	cg.TestNull()
	cg.BranchIfFalse(L2)
	CompileBlock(node.children[1])
	cg.BranchTo(L1)
	cg.PutLabel(L2)
	other_children = node.children[2:]
	for else_if in other_children:
		if else_if.value == "ELSEIF":
			CompileExpression(else_if.children[0])
			cg.TestNull()
			L2 = cg.NewLabel()
			cg.BranchIfFalse(L2)
			CompileBlock(else_if.children[1])
			cg.BranchTo(L1)
			cg.PutLabel(L2)
		else:
			CompileBlock(else_if.children[0])
			cg.BranchTo(L1) # This line may be unnecessary
	cg.PutLabel(L1)

def CompileWhile(node):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	cg.PutLabel(L1)
	CompileExpression(node.children[0])
	cg.TestNull()
	cg.BranchIfTrue(L2)
	CompileBlock(node.children[1])
	cg.BranchTo(L1)
	cg.PutLabel(L2)

def CompileLocDecl(node):
	st.AddVariable(node.value["name"], node.value["type"])
	cg.StackAlloc(st.SizeOf(node.value["type"].datatype))
	
	# Add the initializer value if there's one
	if len(node.children) != 0:
		CompileExpression(node.children[0])
		cg.MainToStackTop()

def CompileReturn(node):
	CompileExpression(node.children[0])
	cg.BranchToAnonymous()

def CompileBreak(node):
	cg.EmitLn("; Break here")

def CompileExpression(node):
	if node.type == "BinaryOp":
		return CompileBinaryOp(node)
	elif node.type == "Relation":
		return CompileRelation(node)
	elif node.type == "UnaryOp":
		return CompileUnaryOp(node)
	elif node.type == "Assignement":
		return CompileAssignement(node)
	elif node.type == "FunctionCall":
		return CompileFunctionCall(node)
	elif node.type == "Variable":
		return CompileVariableRead(node)
	elif node.type == "StructMemberAccess":
		return CompileStructMemberAccess(node)
	elif node.type == "StructPointerMemberAccess":
		return CompileStructPointerMemberAccess(node)
	elif node.type == "String":
		return CompileString(node)
	elif node.type == "Dereference":
		return CompileDereference(node)
	elif node.type == "Number":
		return CompileNumber(node)

def CompileBinaryOp(node):
	cg.EmitLn("; BinaryOp here")
	return Type_("VOID")

def CompileRelation(node):
	cg.EmitLn("; Relation here")
	return Type_("VOID")

def CompileUnaryOp(node):
	t = CompileVariableRead(node.children[0])
	if node.value == "++":
		cg.IncrementMain()
	else:
		cg.DecrementMain()
	cg.EmitLn("; Store to variable here")
	return t

def CompileAssignement(node):
	if not node.children[0].type in ["Variable", "Dereference", "StructMemberAccess", "StructPointerMemberAccess"]:
		abort("Cannot assign to something else than a variable")
	CompileExpression(node.children[1])
	return Type_("VOID")

def CompileNumber(node):
	cg.LoadNumber(node.value)
	if node.value <= 255:
		return Type_("CHAR")
	elif node.value <= 65535:
		return Type_("WORD")
	return Type_("INT")

def CompileString(node):
	L = cg.NewLabel()
	cg.EmitLnData(FormatString(L, node.value))
	cg.LoadLabel(L)
	return Type_("CHAR", pointer_level=1)

def CompileVariableRead(node):
	name = node.value
	
	#This might be either a function pointer, or a variable
	if st.IsVariable(name):
		if st.IsVariableGlobal(name):
			if GetVariableType(name).pointer_level != 0:
				cg.LoadGlobalVariable(name, 4)
				return Type_(st.GetVariableType(name).datatype)
			elif IsBuiltInType(st.GetVariableType(name).datatype):
				cg.LoadGlobalVariable(name, SizeOfBuiltIn(st.GetVariableType(name).datatype))
				return Type_(st.GetVariableType(name))
			else:
				abort("Cannot load non-built-in type here")
		else:
			cg.LoadLocalVariable(name) # TODO: pass the offset instead
			return st.GetVariableType(name)
	elif st.IsFunction(name):
		#Just load the function pointer in eax
		cg.LoadFunctionPointer(name)
		return st.GetFunctionType(name)
	else:
		Undefined(name)

def CompileFunctionCall(node):
	name = node.value
	if name == "MAIN":
		abort("cannot call function Main manually")
	if not st.IsFunction(name):
		if IsKeyword(name):
			abort(name + " is misplaced")
		else:
			Undefined(name)
	i = 0
	arg_type_list = st.GetFunctionArgType(name)
	for child in node.children[0].children:
		arg_type = CompileExpression(child)
		if arg_type != arg_type_list[i]:
			# If the type is wrong, we can still check if we can cast
			if not (arg_type.pointer_level == 0 and arg_type_list[i].pointer_level == 0 and IsBuiltInType(arg_type.datatype) and IsBuiltInType(arg_type_list[i].datatype) and SizeOfBuiltIn(arg_type.datatype) <= SizeOfBuiltIn(arg_type_list[i].datatype)):
				abort("wrong type of argument " + str(i) + " while calling " + name + ": " + arg_type.datatype + arg_type.pointer_level * "*" + " instead of " + arg_type_list[i].datatype + arg_type_list[i].pointer_level * "*")
			else:
				pass
		cg.PushMain()
		i += 1
	if i != st.GetFunctionArgCount(name):
		abort("wrong number of arguments while calling " + name + ": " + str(i) + " instead of " + str(st.GetFunctionArgType(name)))
	cg.CallFunction(name)
	return st.GetFunctionType(name)