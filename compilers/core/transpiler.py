"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The fourth stage of the compiler, that takes an AST and outputs assembly code
"""

import sys

from core.helpers import *
import core.symboltable as st
import core.codegen as cg

AST = None

allocated_stack_units = 0 # Number of local variables on the stack

# Error functions
def abort(s):
	# I'm still yet to find how to use file_name, line_number and character_number here
	# print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
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
			if node.children != []:
				CompileExpression(node.children[0])
				StoreToGlobalVariable(node.value["name"], st.SizeOf(node.value["type"].datatype))
	
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
	
	# print(cg.GetOutput())
	return cg.GetOutput()

def CompileFunction(node):
	global allocated_stack_units
	
	func_name = node.value["name"]
	
	cg.PutIdentifier(func_name)
	cg.FunctionHeader()
	
	allocated_stack_units = 0
	
	stack_offset = -len(node.children[0].children) - 1
	for arg in node.children[0].children:
		st.AddVariable(arg["name"], arg["type"], stack_offset=stack_offset)
		stack_offset += 1
	
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
	cg.BranchIfTrue(L2)
	CompileBlock(node.children[1])
	if len(node.children) != 2:
		cg.BranchTo(L1)
	cg.PutLabel(L2)
	other_children = node.children[2:]
	for i in range(len(other_children)):
		if other_children[i].value == "ELSEIF":
			L2 = cg.NewLabel()
			CompileExpression(other_children[i].children[0])
			cg.TestNull()
			cg.BranchIfTrue(L2)
			CompileBlock(other_children[i].children[1])
			if i != len(other_children) - 1:
				cg.BranchTo(L1)
			cg.PutLabel(L2)
		else:
			CompileBlock(other_children[i].children[0])
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
	global allocated_stack_units
	
	allocated_stack_units += 1
	
	st.AddVariable(node.value["name"], node.value["type"], stack_offset = allocated_stack_units)
	cg.StackAlloc(1) # TODO: right now this does but I might have to change it
	
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
	t1 = CompileExpression(node.children[0])
	cg.PushMain()
	t2 = CompileExpression(node.children[1])
	if node.value == "+":
		cg.AddMainStackTop()
	elif node.value == "-":
		cg.SubMainStackTop()
	elif node.value == "*":
		cg.MulMainStackTop()
	elif node.value == "/":
		cg.DivMainStackTop()
	elif node.value == "%":
		cg.ModMainStackTop()
	elif node.value == "<<":
		cg.ShlMainStackTop()
	elif node.value == ">>":
		cg.ShrMainStackTop()
	elif node.value == "&&":
		cg.AndMainStackTop()
	elif node.value == "||":
		cg.OrMainStackTop()
	elif node.value == "~":
		cg.XorMainStackTop()
	return Type_("VOID") # TODO: calculate the returned type

# Only unsigned comparisons are supported right now
def CompileRelation(node):
	CompileExpression(node.children[0])
	cg.PushMain()
	CompileExpression(node.children[1])
	cg.CompareStackTopMain()
	if node.value == "==":
		cg.SetIfEqual() # TODO: I'm pretty certain this can be optimized,
	elif node.value == "!=":#       even if it has to be in post production
		cg.SetIfNotEqual()
	elif node.value == "<=":
		cg.SetIfLessOrEqual()
	elif node.value == ">=":
		cg.SetIfAboveOrEqual()
	elif node.value == ">":
		cg.SetIfAbove()
	elif node.value == "<":
		cg.SetIfLess()
	cg.StackFree(1)
	return Type_("CHAR")

def CompileUnaryOp(node):
	if node.value == "!":
		t = CompileExpression(node.children[0])
		cg.NegateMain()
		return t
	else:
		t = CompileVariableRead(node.children[0])
		if node.value == "++":
			cg.IncrementMain()
		elif node.value == "--":
			cg.DecrementMain()
		CompileStore(node.children[0])
		return t

def CompileAssignement(node):
	if not node.children[0].type in ["Variable", "Dereference", "StructMemberAccess", "StructPointerMemberAccess"]:
		abort("Cannot assign to something else than a variable")
	t = CompileExpression(node.children[1])
	CompileStore(node.children[0])
	return t

def CompileStore(node):
	# This may be either a variable, a dereference, a struct member access or a struct pointer member access
	if node.type == "Variable":
		name = node.value
		t = st.GetVariableType(name)
		if st.IsVariableGlobal(name):
			if t.pointer_level != 0:
				cg.StoreToGlobalVariable(name, 4)
			else:
				cg.StoreToGlobalVariable(name, st.SizeOf(t.datatype))
		else:
			if t.pointer_level != 0:
				cg.StoreToLocalVariable(st.GetLocalVariableOffset(name) * 4, 4)
			else:
				cg.StoreToLocalVariable(st.GetLocalVariableOffset(name) * 4, st.SizeOf(t.datatype))
		return t
	elif node.type == "Dereference":
		if node.children[0].type == "Dereference":
			cg.EmitLn("; Nested dereference store here")
			return Type_("VOID")
		else:
			if node.children[0].type != "Variable":
				abort("Undereferencable expression")
			name = node.children[0].value
			t = st.GetVariableType(name)
			if t.pointer_level == 0:
				abort("The variable " + name + " is not a pointer")
			cg.PushMain()
			CompileVariableRead(node.children[0])
			cg.StoreDereferenceMain(SizeOfBuiltIn(t.datatype)) # TODO: Maybe st.SizeOf would be more suited ?
			cg.StackFree(1)
			return Type_(t.datatype, t.pointer_level - 1)
	elif node.type == "StructMemberAccess":
		cg.EmitLn("; Struct member access here")
		return Type_("VOID")
	elif node.type == "StructPointerMemberAccess":
		cg.EmitLn("; Struct pointer member access here")
		return Type_("VOID")

def CompileNumber(node):
	cg.LoadNumber(node.value)
	if node.value <= 0xff:
		return Type_("CHAR")
	elif node.value <= 0xffff:
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
			if st.GetVariableType(name).pointer_level != 0:
				cg.LoadGlobalVariable(name, 4)
			elif IsBuiltInType(st.GetVariableType(name).datatype):
				cg.LoadGlobalVariable(name, SizeOfBuiltIn(st.GetVariableType(name).datatype))
			else:
				abort("Cannot load non-built-in type here")
			return Type_("INT")
		else:
			if st.GetVariableType(name).pointer_level != 0:
				cg.LoadLocalVariable(st.GetLocalVariableOffset(name) * 4, 4)
			elif IsBuiltInType(st.GetVariableType(name).datatype):
				cg.LoadLocalVariable(st.GetLocalVariableOffset(name) * 4, SizeOfBuiltIn(st.GetVariableType(name).datatype))
			else:
				abort("Cannot load non-built-in type here")
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
				# TODO: What is right below is a hack, I'm just waiting to implement type casts to remove it
				# abort("wrong type of argument " + str(i) + " while calling " + name + ": " + arg_type.datatype + arg_type.pointer_level * "*" + " instead of " + arg_type_list[i].datatype + arg_type_list[i].pointer_level * "*")
				pass
			else:
				pass
		cg.PushMain()
		i += 1
	if i != st.GetFunctionArgCount(name):
		abort("wrong number of arguments while calling " + name + ": " + str(i) + " instead of " + str(st.GetFunctionArgType(name)))
	cg.CallFunction(name)
	
	if st.GetFunctionArgCount(name) != 0:
		cg.StackFree(st.GetFunctionArgCount(name))
	
	return st.GetFunctionType(name)

def CompileDereference(node):
	if node.children[0].type == "Dereference":
		t = CompileDereference(node.children[0])
		cg.DereferenceMain(0) # TODO: I'm pretty sure this is more subtle than that around types
		return Type_(t.datatype, t.pointer_level - 1)
	else:
		if node.children[0].type == "Variable":
			name = node.children[0].value
			t = st.GetVariableType(name)
			if t.pointer_level == 0:
				abort("Variable " + name + " is not a pointer")
			CompileVariableRead(node.children[0])
			size = SizeOfBuiltIn(t.datatype) #TODO: Idk if I need to call st.SizeOf here
			cg.DereferenceMain(size)
			return Type_(t.datatype)
		elif node.children[0].type == "StructMemberAccess":
			cg.EmitLn("; StructMemberAccess dereference here")
			abort("Undereferencable expression") #TODO: I know this shouldn't abort, I just don't want to implement it right now
		elif node.children[0].type == "StructPointerMemberAccess":
			cg.EmitLn("; StructPointerMemberAccess dereference here")
			abort("Undereferencable expression")
		else:
			abort("Undereferencable expression")

def CompileStructMemberAccess(node):
	identifier_name = node.value
	t = st.GetVariableType(identifier_name)
	if t.pointer_level != 0:
		abort("Cannot access the members of a pointer on struct with '.'")
	struct_name = t.datatype
	cg.EmitLn("; Struct member access here")

def CompileStructPointerMemberAccess(node):
	identifier_name = node.value
	t = st.GetVariableType(identifier_name)
	if t.pointer_level == 0:
		abort("Cannot access the members of a struct with '->'")
	struct_name = t.datatype
	cg.EmitLn("; Struct pointer member access here")
