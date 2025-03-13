"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The fourth stage of the compiler, that takes an AST and generates assembly code from it
"""

TEST_MODE = False
last_err = ''

import sys

from core.helpers import *
import core.symboltable as st
import core.codegen as cg

AST = None

allocated_stack_units = 0 # Number of local variables on the stack

# Error functions
def abort(s):
	global last_err
	
	if TEST_MODE:
		last_err = s
		raise TestModeError
	
	# I'm still yet to find how to use file_name, line_number and character_number here
	# print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	# For now, just print it raw
	print("Error: " + s, file=sys.stderr)
	sys.exit(-1)

def warning(s):
	print("Warning: " + s)

def Expected(s):
	abort("Expected " + s)

def Undefined(n):
	abort("Undefined variable (" + n + ")")

def GetResultingType(t1,t2): # TODO: I have no idea what I'm doing
	if t1.pointer_level != 0:
		t1 = Type_("uint32_t",pointer_level=0)
	if t2.pointer_level != 0:
		t2 = Type_("uint32_t",pointer_level=0)
	
	table = {
	(Type_("uint8_t"),Type_("uint8_t")): Type_("uint8_t"),
	(Type_("uint8_t"),Type_("uint16_t")): Type_("uint16_t"),
	(Type_("uint8_t"),Type_("uint32_t")): Type_("uint32_t"),
	(Type_("uint16_t"),Type_("uint16_t")): Type_("uint16_t"),
	(Type_("uint16_t"),Type_("uint32_t")): Type_("uint32_t"),
	(Type_("uint32_t"),Type_("uint32_t")): Type_("uint32_t"),
	(Type_("char"),Type_("char")): Type_("char"),
	(Type_("int"),Type_("int")): Type_("int"),
	(Type_("int"),Type_("char")): Type_("int"),
	}
	
	return table[(t1,t2)]

# A debug routine to dump the AST
tab_number = 0
def print_node(node):
	global tab_number
	
	print("\t" * tab_number,"Node",node.type,"with value",node.value)
	if node.children != []:
		tab_number += 1
		
		for child in node.children:
			try:
				print_node(child)
			except:
				print("\t" * tab_number,child)
		
		tab_number -= 1


def transpile():
	
	for node in AST.children:
		if node.type == "FunctionDeclaration":
			st.AddFunction(node.value["name"], node.value["type"], attributes=node.children[0], args=node.children[1].children, function_body=False)
		elif node.type == "StructDecl":
			st.AddStruct(node.value, node.children)
		elif node.type == "GlobalDecl":
			st.AddVariable(node.value["name"], node.value["type"], True)
			cg.AllocateGlobalVariable(node.value["name"], st.SizeOf(node.value["type"].datatype))
			if node.children != []:
				CompileExpression(node.children[0])
				StoreToGlobalVariable(node.value["name"], st.SizeOf(node.value["type"].datatype))
		else:
			# The only option left is it's a function
			CompileFunction(node)
	
	# After compiling everything, check if MAIN fullfills it's specification
	main_func = None
	for node in AST.children:
		if node.value["name"] == "main":
			main_func = node
	
	if main_func == None:
		abort("No main function")
	if st.GetFunctionArgCount("main") != 0:
		abort("The main function should take no arguments")
	if st.GetFunctionType("main") != Type_("int", pointer_level=0):
		abort("The main function should only return an int")

def GetFormattedOutput(fmt):
	return cg.GetFreestandingOutput() if fmt == "f" else cg.GetWindowsOutput()

def CompileFunction(node):
	global allocated_stack_units
	
	# First of all, add it to the symbol table for later references
	
	func_name = node.value["name"]
	
	# If it's already in there, check if the declaration matches the implementation
	if st.IsFunction(func_name):
		CheckRedefinition(node)
	else:
		st.AddFunction(node.value["name"], node.value["type"], attributes=node.children[0], args=node.children[1].children)
	
	cg.PutIdentifier(func_name)
	
	CompileStackFrameBegin(node)
	
	allocated_stack_units = 0
	
	stack_offset = -len(node.children[1].children) - 1
	node.children[1].children.reverse()
	
	for arg in node.children[1].children:
		st.AddVariable(arg["name"], arg["type"], stack_offset=stack_offset)
		stack_offset += 1
	
	node.children[1].children.reverse()
	
	CompileBlock(node.children[2])
	
	cg.PutAnonymousLabel()
	
	CompileStackFrameEnd(node)
	CompileEpilog(node)
	
	st.DeleteLocalVariables()

def CheckRedefinition(node):
	func_name = node.value["name"]
	
	if st.IsFunctionBodyDefined(func_name):
		abort("function redefinition (" + func_name + ")")
	
	if node.children[1].children != st.GetFunctionArgList(func_name):
		abort("the argument list of " + func_name + " does not match its definition")
	
	if node.value["type"] != st.GetFunctionType(func_name):
		abort("the type of " + func_name + " does not match its definition")
	
	if st.GetFunctionAttributes(func_name) != node.children[0]:
		abort("the attributes in the definition of " + func_name + " do not match the definition") # TODO: This shouldn't abort
	
	st.SetFunctionBodyAsDefined(func_name)

def CompileStackFrameBegin(node):
	func_name = node.value["name"]
	
	if st.FunctionHasAttr(func_name, Attribute(vendor="roverc",name="interrupt")):
		cg.PushAll()
	if not st.FunctionHasAttr(func_name, Attribute(vendor="roverc",name="naked")):
		cg.OpenStackFrame()

def CompileStackFrameEnd(node):
	func_name = node.value["name"]
	
	if not st.FunctionHasAttr(func_name, Attribute(vendor="roverc",name="naked")):
		cg.CloseStackFrame()
	if st.FunctionHasAttr(func_name, Attribute(vendor="roverc",name="interrupt")):
		cg.PopAll()

def CompileEpilog(node):
	func_name = node.value["name"]
	
	if st.FunctionHasAttr(func_name, Attribute(vendor="roverc",name="interrupt")):
		if st.FunctionHasAttr(func_name, Attribute(name='__stdcall')):
			abort('interrupts cannot use conventions with callee stack cleaning (Ex: stdcall)')
		cg.InterruptReturn()
	else:
		cg.StandardReturn(len(node.children[1].children) * 4 if st.FunctionHasAttr(func_name, Attribute(name='__stdcall')) else 0)

def CompileBlock(node, can_break=False, can_continue=False, break_label='', continue_label=''):
	for statement in node.children:
		if statement.type == "LocDecl":
			CompileLocDecl(statement)
		elif statement.value == "ASM":
			CompileAsm(statement)
		elif statement.value == "IF":
			CompileIf(statement, can_break, can_continue, break_label, continue_label)
		elif statement.value == "WHILE":
			CompileWhile(statement)
		elif statement.value == "FOR":
			CompileFor(statement)
		elif statement.value == "SWITCH":
			CompileSwitch(statement)
		elif statement.value == "RETURN":
			CompileReturn(statement)
		elif statement.value == "Block":
			CompileBlock(statement, can_break, can_continue, break_label, continue_label)
		elif statement.value == "BREAK":
			CompileBreak(statement, can_break, break_label)
		elif statement.value == "CONTINUE":
			CompileContinue(statement, can_continue, continue_label)
		else:
			CompileExpression(statement)

def CompileAsm(node):
	cg.EmitLn(node.children[0].value)

def CompileIf(node, can_break=False, can_continue=False, break_label='', continue_label=''):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	CompileExpression(node.children[0])
	cg.TestNull()
	cg.BranchIfTrue(L2)
	CompileBlock(node.children[1], can_break, can_continue, break_label, continue_label)
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
			CompileBlock(other_children[i].children[1], can_break, can_continue, break_label, continue_label)
			if i != len(other_children) - 1:
				cg.BranchTo(L1)
			cg.PutLabel(L2)
		else:
			CompileBlock(other_children[i].children[0], can_break, can_continue, break_label, continue_label)
	cg.PutLabel(L1)

def CompileWhile(node):
	L1, L2 = cg.NewLabel(), cg.NewLabel()
	cg.PutLabel(L1)
	CompileExpression(node.children[0])
	cg.TestNull()
	cg.BranchIfTrue(L2)
	CompileBlock(node.children[1], can_break=True, can_continue=True, break_label=L2, continue_label=L1)
	cg.BranchTo(L1)
	cg.PutLabel(L2)

def CompileFor(node):
	L1, L2, L3 = cg.NewLabel(), cg.NewLabel(), cg.NewLabel()
	if node.children[0].type == "LocDecl":
		CompileLocDecl(node.children[0])
	else:
		CompileExpression(node.children[0])
	cg.PutLabel(L1)
	CompileExpression(node.children[1])
	cg.TestNull()
	cg.BranchIfTrue(L2)
	CompileBlock(node.children[3], can_break=True, can_continue=True, break_label=L2, continue_label=L3)
	cg.PutLabel(L3)
	CompileExpression(node.children[2])
	cg.BranchTo(L1)
	cg.PutLabel(L2)

def CompileSwitch(node):
	CompileExpression(node.children[0])
	labels = []
	L1 = cg.NewLabel()
	for c in node.children[1]:
		if c:
			L = cg.NewLabel()
			cg.Switch(c.value, L)
			labels.append(L)
	if node.children[1][-1] == None:
		CompileBlock(node.children[-1], can_break=True, break_label=L1)
		cg.BranchTo(L1)
	
	for i in range(len(labels)):
		cg.PutLabel(labels[i])
		CompileBlock(node.children[i + 2], can_break=True, break_label=L1)
	
	cg.PutLabel(L1)

def CompileLocDecl(node):
	global allocated_stack_units
	
	allocated_stack_units += 1
	
	st.AddVariable(node.value["name"], node.value["type"], stack_offset = allocated_stack_units)
	
	# Add the initializer value if there's one
	if len(node.children) != 0:
		CompileExpression(node.children[0])
		cg.PushMain()
	else:
		cg.StackAlloc(1) # TODO: right now this does but I might have to change it

def CompileReturn(node):
	CompileExpression(node.children[0])
	cg.BranchToAnonymous()

def CompileBreak(node, can_break, break_label):
	if not can_break:
		abort("break is misplaced")
	cg.BranchTo(break_label)

def CompileContinue(node, can_continue, continue_label):
	if not can_continue:
		abort("continue is misplaced")
	cg.BranchTo(continue_label)

def CompileExpression(node):
	if node.type == "BinaryOp":
		return CompileBinaryOp(node)
	elif node.type == "Relation":
		return CompileRelation(node)
	elif node.type == "TernaryOp":
		return CompileTernaryOp(node)
	elif node.type == "PrefixUnaryOp":
		return CompilePrefixUnaryOp(node)
	elif node.type == "PostfixUnaryOp":
		return CompilePostfixUnaryOp(node)
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

def CompileTernaryOp(node):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	CompileExpression(node.children[0])
	cg.TestNull()
	cg.BranchIfTrue(L2)
	CompileExpression(node.children[1])
	cg.BranchTo(L1)
	cg.PutLabel(L2)
	CompileExpression(node.children[2])
	cg.PutLabel(L1)
	
	return Type_("void")

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
		cg.AndMainStackTop() # TODO: make it lazy
	elif node.value == "&":
		cg.AndMainStackTop()
	elif node.value == "||":
		cg.OrMainStackTop() # TODO: make it lazy
	elif node.value == "|":
		cg.OrMainStackTop()
	elif node.value == "~":
		cg.NotMainStackTop()
	elif node.value == "^":
		cg.XorMainStackTop()
	return Type_("void") # TODO: calculate the returned type

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
	return Type_("char")

def CompilePrefixUnaryOp(node):
	if node.value == "!":
		t = CompileExpression(node.children[0])
		cg.NotMain()
		return t
	else:
		t = CompileVariableRead(node.children[0])
		if node.value == "++":
			cg.IncrementMain()
		elif node.value == "--":
			cg.DecrementMain()
		CompileStore(node.children[0])
		return t

def CompilePostfixUnaryOp(node):
	t = CompileVariableRead(node.children[0])
	cg.PrimaryToSecondary()
	if node.value == "++":
		cg.IncrementMain()
	elif node.value == "--":
		cg.DecrementMain()
	CompileStore(node.children[0])
	cg.SecondaryToPrimary()
	return t

def CompileAssignement(node):
	if not node.children[0].type in ["Variable", "Dereference", "StructMemberAccess", "StructPointerMemberAccess"]:
		abort("Cannot assign to something else than a variable")
	if node.value == "=":
		t = CompileExpression(node.children[1])
		CompileStore(node.children[0])
	else:
		CompileVariableRead(node.children[0])
		cg.PushMain()
		t = CompileExpression(node.children[1])
		if node.value == "+=":
			cg.AddMainStackTop()
		elif node.value == "-=":
			cg.SubMainStackTop()
		elif node.value == "*=":
			cg.MulMainStackTop()
		elif node.value == "/=":
			cg.DivMainStackTop()
		elif node.value == ">>=":
			cg.ShrMainStackTop()
		elif node.value == "<<=":
			cg.ShlMainStackTop()
		elif node.value == "&=":
			cg.AndMainStackTop()
		elif node.value == "|=":
			cg.OrMainStackTop()
		elif node.value == "^=":
			cg.XorMainStackTop()
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
			return Type_("void")
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
		return Type_("void")
	elif node.type == "StructPointerMemberAccess":
		cg.EmitLn("; Struct pointer member access here")
		return Type_("void")

def CompileNumber(node):
	cg.LoadNumber(node.value)
	if node.value <= 0xff:
		return Type_("char")
	elif node.value <= 0xffff:
		return Type_("word")
	return Type_("int")

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
	if name == "main":
		abort("cannot call function Main manually")
	if not st.IsFunction(name):
		if IsKeyword(name):
			abort(name + " is misplaced")
		else:
			Undefined(name)
	
	i = 0
	arg_type_list = st.GetFunctionArgType(name)
	node.children[0].children.reverse() # We use cdecl, so arguments are pushed in reverse
	
	for child in node.children[0].children:
		arg_type = CompileExpression(child)
		if arg_type != arg_type_list[i]:
			# If the type is wrong, we can still check if we can cast
			if not (arg_type.pointer_level == 0 and arg_type_list[i].pointer_level == 0 and IsBuiltInType(arg_type.datatype)
			and IsBuiltInType(arg_type_list[i].datatype) and SizeOfBuiltIn(arg_type.datatype) <= SizeOfBuiltIn(arg_type_list[i].datatype)):
				# TODO: What is right below is a hack, I'm just waiting to implement type casts to remove it
				# abort(f"wrong type of argument {i} while calling {name}: {arg_type.datatype + arg_type.pointer_level * '*'} instead of {arg_type_list[i].datatype + arg_type_list[i].pointer_level * '*'}")
				pass
			else:
				pass
		cg.PushMain()
		i += 1
	
	node.children[0].children.reverse() # Re-reverse so we can re-use the values, though idk if we ever do that
	
	if i != st.GetFunctionArgCount(name):
		abort("wrong number of arguments while calling " + name + ": " + str(i) + " instead of " + str(st.GetFunctionArgType(name)))
	cg.CallFunction(name)
	
	if st.GetFunctionArgCount(name) != 0 and st.FunctionHasAttr(name, Attribute(name='__cdecl')):
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
			return Type_(t.datatype, t.pointer_level - 1)
		elif node.children[0].type == "StructMemberAccess":
			cg.EmitLn("; StructMemberAccess dereference here")
			abort("Not implemented") #TODO: I know this shouldn't abort, I just don't want to implement it right now
		elif node.children[0].type == "StructPointerMemberAccess":
			cg.EmitLn("; StructPointerMemberAccess dereference here")
			abort("Not implemented")
		else:
			abort("Undereferencable expression")

def CompileStructMemberAccess(node):
	identifier_name = node.value
	t = st.GetVariableType(identifier_name)
	if t.pointer_level != 0:
		abort("Cannot access the members of a pointer on struct with '.'")
	struct_name = t.datatype
	cg.EmitLn("; Struct member access here")
	abort("Structs are not implemented yet")

def CompileStructPointerMemberAccess(node):
	identifier_name = node.value
	t = st.GetVariableType(identifier_name)
	if t.pointer_level == 0:
		abort("Cannot access the members of a struct with '->'")
	struct_name = t.datatype
	member_name = node.children[0].value
	member_t = st.GetMemberType(struct_name, member_name)
	if not IsBuiltInType(member_t.datatype):
		abort("not implemented yet")
	else:
		CompileVariableRead(node)
		cg.PushMain()
		cg.LoadNumber(st.GetStructMemberOffset(struct_name, member_name))
		cg.AddMainStackTop()
		cg.DereferenceMain(SizeOfBuiltIn(member_t.datatype))
		return Type_(member_t.datatype)
