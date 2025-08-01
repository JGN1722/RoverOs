"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The fourth stage of the compiler, that takes an AST and generates assembly code from it
"""

# There are 10 TODOs

TEST_MODE = False
last_err = ''

import sys

from core.helpers import *
import core.symboltable as st
import core.codegen as cg
import core.ctypes as ctypes

struct_ST = st.SymbolTable()
ident_ST = st.IdentSymbolTable()
string_ST = st.SymbolTable()
AST = None

allocated_stack_units = 0 # Number of local variables on the stack

# Error functions
def abort(s):
	global last_err
	
	if TEST_MODE:
		last_err = s
		raise TestModeError
	
	# I'm still yet to find how to use file_name, line_number and character_number here
	# For now, just print it raw
	print("Error: " + s, file=sys.stderr)
	sys.exit(-1)

def warning(s):
	print("Warning: " + s)

def Expected(s):
	abort("Expected " + s)

def Undefined(n):
	if IsKeyword(name):
		abort(name + ' is misplaced')
	else:
		abort("Undefined variable (" + n + ")")

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

# Type utilities
def GetTypeSize(t):
	if hasattr(t, 'size'):
		return t.size
	elif isinstance(t, ctypes.StructType):
		return sum(GetTypeSize(member.value['type']) for member in struct_ST.get_symbol_value(t.name))
	else:
		return 0

def CanCastImplicitly(t, dst):
	if t == dst:
		return True
	elif isinstance(t, ctypes.NumberType) and isinstance(dst, ctypes.NumberType):
		return True
	elif isinstance(t, ctypes.NumberType) and isinstance(dst, ctypes.PointerType):
		return True
	elif isinstance(t, ctypes.PointerType) and isinstance(dst, ctypes.PointerType) and isinstance(t.arg, ctypes.VoidType):
		return True
	return False


def transpile():
	
	for node in AST.children:
		if node.type == "StructDecl":
			struct_ST.add_symbol(node.value, node.children)
		elif node.type == "Decl":
			CompileDecl(node)
	
	# After compiling everything, check if MAIN fullfills its specification
	main = ident_ST.get_symbol_value('main')
	if main == None:
		abort('No main function')
	valid_type_1 = ctypes.FunctionType(args=[ctypes.VoidType()], ret=ctypes.NumberType(size=4))
	valid_type_2 = ctypes.FunctionType(
		args=[ctypes.NumberType(size=4), ctypes.PointerType(arg=ctypes.PointerType(arg=ctypes.NumberType(size=1), const=False), const=False)],
		ret=ctypes.NumberType(size=4)
	)
	if main['type'] != valid_type_1 and main['type'] != valid_type_2:
		abort('Main function should take either no arguments or an int and a char**, and return int')
	
	for s in ident_ST.scopes:
		for i in s.values():
			if not isinstance(i['value']['type'], ctypes.FunctionType):
				continue
			if not i['body']:
				abort('Function ' + i['value']['name'] + ' was declared but never defined')

def GetFormattedOutput(fmt):
	return cg.GetFreestandingOutput() if fmt == "f" else cg.GetWindowsOutput()

def CompileDecl(node):
	if isinstance(node.value['type'], ctypes.FunctionType):
		CompileFunction(node)
	else:
		CompileGlobalDecl(node)

def CompileGlobalDecl(node):
	name = node.value['name']
	if ident_ST.symbol_exists(name):
		abort('Name redefinition (' + name + ')')
	ident_ST.add_symbol(name, node.value)
	t = node.value['type']
	size = GetTypeSize(t)
	if node.children != []:
		if not isinstance(t, ctypes.NumberType):
			abort('Cannot initialize a non-number variable')
		if node.children[0].type != 'Number':
			abort('Initializer element is not constant')
		cg.AllocateInitGlobalVariable(name, size if size != 0 else abort('Unknown storage size of ' + name), node.children[0].value)
	else:
		cg.AllocateGlobalVariable(name, size if size != 0 else abort('Unknown storage size of ' + name))

def CompileFunction(node):
	global allocated_stack_units
	
	# First of all, add it to the symbol table for later references
	
	func_name = node.value['name']
	t = node.value['type']
	
	# If it's already in there, check if the declaration matches the implementation
	if ident_ST.symbol_exists(func_name):
		CheckRedefinition(node)
	else:
		if node.children == []:
			ident_ST.add_symbol(func_name, node.value, function_body=False)
			return
		ident_ST.add_symbol(func_name, node.value)
	
	cg.PutIdentifier(func_name)
	CompileStackFrameBegin(node)
	
	BlockProlog()
	
	allocated_stack_units = 0
	
	stack_offset = -len(node.value['type'].args) - 1
	node.value['type'].args.reverse()
	
	for arg in node.value['type'].args:
		if arg['name']: ident_ST.add_symbol(arg['name'], arg, stack_offset=stack_offset)
		stack_offset += 1
	
	node.value['type'].args.reverse()
	
	CompileBlock(node.children[0])
	
	cg.PutAnonymousLabel()
	
	BlockEpilog()
	
	CompileStackFrameEnd(node)
	CompileEpilog(node)

def CheckRedefinition(node):
	func_name = node.value['name']
	
	if ident_ST.get_symbol_body(func_name):
		abort("function redefinition (" + func_name + ")")
	
	if node.value != ident_ST.get_symbol_value(func_name):
		abort('the type of ' + func_name + ' does not match the definition')
	
	ident_ST.set_symbol_body(func_name, True)

def CompileStackFrameBegin(node):
	func_name = node.value['name']
	
	if Attribute(vendor='roverc',name='interrupt') in node.value['attributes']:
		cg.PushAll()
	if not Attribute(vendor='roverc', name='naked') in node.value['attributes']:
		cg.OpenStackFrame()

def CompileStackFrameEnd(node):
	func_name = node.value['name']
	
	if not Attribute(vendor='roverc', name='naked') in node.value['attributes']:
		cg.CloseStackFrame()
	if Attribute(vendor='roverc',name='interrupt') in node.value['attributes']:
		cg.PopAll()

def CompileEpilog(node):
	func_name = node.value['name']
	
	if Attribute(vendor='roverc',name='interrupt') in node.value['attributes']:
		if Attribute(name='__stdcall') in node.value['attributes']:
			abort('interrupts cannot use conventions with callee stack cleaning (Ex: stdcall)')
		cg.InterruptReturn()
	else:
		cg.StandardReturn(len(node.children[1].children) * 4 if Attribute(name='__stdcall') in node.value['attributes'] else 0)

def CompileBlock(node, can_break=False, can_continue=False, break_label='', continue_label=''):
	BlockProlog() # TODO: pop the vars, idk man that's terrible
	for statement in node.children:
		if statement.type == 'Decl':
			CompileLocDecl(statement)
		elif statement.value == 'ASM':
			CompileAsm(statement)
		elif statement.value == 'IF':
			CompileIf(statement, can_break, can_continue, break_label, continue_label)
		elif statement.value == 'WHILE':
			CompileWhile(statement)
		elif statement.value == 'FOR':
			CompileFor(statement)
		elif statement.value == 'SWITCH':
			CompileSwitch(statement)
		elif statement.value == 'DOWHILE':
			CompileDoWhile(statement)
		elif statement.value == 'RETURN':
			CompileReturn(statement)
		elif statement.value == 'Block':
			CompileBlock(statement, can_break, can_continue, break_label, continue_label)
		elif statement.value == 'BREAK':
			CompileBreak(statement, can_break, break_label)
		elif statement.value == 'CONTINUE':
			CompileContinue(statement, can_continue, continue_label)
		else:
			CompileStatementExpression(statement)
	BlockEpilog()

def BlockProlog():
	ident_ST.new_scope()
	struct_ST.new_scope()

def BlockEpilog():
	ident_ST.close_scope()
	struct_ST.close_scope()

def CompileAsm(node):
	cg.EmitLn(node.children[0].value)

def CompileIf(node, can_break=False, can_continue=False, break_label='', continue_label=''):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	CompileFalseCondition(node.children[0], L2)
	CompileBlock(node.children[1], can_break, can_continue, break_label, continue_label)
	if len(node.children) != 2:
		cg.BranchTo(L1)
	cg.PutLabel(L2)
	other_children = node.children[2:]
	for i in range(len(other_children)):
		if other_children[i].value == 'ELSEIF':
			L2 = cg.NewLabel()
			CompileFalseCondition(other_children[i].children[0], L2)
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
	CompileFalseCondition(node.children[0], L2)
	CompileBlock(node.children[1], can_break=True, can_continue=True, break_label=L2, continue_label=L1)
	cg.BranchTo(L1)
	cg.PutLabel(L2)

def CompileFor(node):
	L1, L2, L3 = cg.NewLabel(), cg.NewLabel(), cg.NewLabel()
	BlockProlog()
		
	if node.children[0].type == "Decl":
		CompileLocDecl(node.children[0])
	else:
		CompileStatementExpression(node.children[0])
	cg.PutLabel(L1)
	CompileFalseCondition(node.children[1], L2)
	
	CompileBlock(node.children[3], can_break=True, can_continue=True, break_label=L2, continue_label=L3)
	cg.PutLabel(L3)
	
	CompileStatementExpression(node.children[2])
	cg.BranchTo(L1)
	cg.PutLabel(L2)
	
	BlockEpilog()

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
		L = cg.NewLabel()
		cg.BranchTo(L)
		labels.append(L)
	else:
		cg.BranchTo(L1)
	
	for i in range(len(labels)):
		cg.PutLabel(labels[i])
		CompileBlock(node.children[i + 2], can_break=True, break_label=L1)
	
	cg.PutLabel(L1)

def CompileDoWhile(node):
	L1, L2, L3 = cg.NewLabel(), cg.NewLabel(), cg.NewLabel()
	cg.PutLabel(L1)
	CompileBlock(node.children[0], can_break=True, can_continue=True, break_label=L2, continue_label=L3)
	cg.PutLabel(L3)
	CompileTrueCondition(node.children[1], L1)
	cg.PutLabel(L2)

def CompileLocDecl(node):
	global allocated_stack_units
	
	allocated_stack_units += 1
	
	ident_ST.add_symbol(node.value['name'], node.value, stack_offset=allocated_stack_units)
	
	# Add the initializer value if there's one
	if len(node.children) != 0:
		CompileExpression(node.children[0])
		cg.PushMain()
	else:
		size = GetTypeSize(node.value['type'])
		if size == 0:
			abort('storage size of ' + node.value['name'] + ' unknown')
		cg.StackAlloc(size)

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

def CompileStatementExpression(node):
	if node.type == "PrefixUnaryOp":
		return CompileStatementPrefixUnaryOp(node)
	elif node.type == "PostfixUnaryOp":
		return CompileStatementPostfixUnaryOp(node)
	else:
		CompileExpression(node)

def CompileFalseCondition(node, L):
	# Branch to the label if the condition is False
	if node.type == "Relation":
		CompileSingleRelation(node)
		
		if node.value == "==":
			cg.BranchIfNotEqual(L)
		elif node.value == "!=":
			cg.BranchIfEqual(L)
		elif node.value == "<=":
			cg.BranchIfAbove(L)
		elif node.value == ">=":
			cg.BranchIfLess(L)
		elif node.value == ">":
			cg.BranchIfLessOrEqual(L)
		elif node.value == "<":
			cg.BranchIfAboveOrEqual(L)
	
	elif node.type == "Number":
		if node.value == 0:
			cg.BranchTo(L)
		else:
			pass
	
	else:
		CompileExpression(node)
		cg.TestNull()
		cg.BranchIfTrue(L)

def CompileTrueCondition(node, L):
	# Branch to the label if the condition is True
	if node.type == "Relation":
		CompileSingleRelation(node)
		
		if node.value == "==":
			cg.BranchIfEqual(L)
		elif node.value == "!=":
			cg.BranchIfNotEqual(L)
		elif node.value == "<=":
			cg.BranchIfLessOrEqual(L)
		elif node.value == ">=":
			cg.BranchIfAboveOrEqual(L)
		elif node.value == ">":
			cg.BranchIfAbove(L)
		elif node.value == "<":
			cg.BranchIfLess(L)
	
	elif node.type == "Number":
		if node.value == 0:
			pass
		else:
			cg.BranchTo(L)
	
	else:
		CompileBinaryOp(node)
		cg.TestNull()
		cg.BranchIfFalse(L)

def CompileExpression(node):
	if node.type == 'BinaryOp':
		return CompileBinaryOp(node)
	elif node.type == 'Relation':
		return CompileRelation(node)
	elif node.type == 'TernaryOp':
		return CompileTernaryOp(node)
	elif node.type == 'PrefixUnaryOp':
		return CompilePrefixUnaryOp(node)
	elif node.type == 'PostfixUnaryOp':
		return CompilePostfixUnaryOp(node)
	elif node.type == 'Assignement':
		return CompileAssignement(node)
	elif node.type == 'FunctionCall':
		return CompileFunctionCall(node)
	elif node.type == 'Variable':
		return CompileVariableRead(node)
	elif node.type == 'StructMemberAccess':
		return CompileStructMemberAccess(node)
	elif node.type == 'StructPointerMemberAccess':
		return CompileStructPointerMemberAccess(node)
	elif node.type == 'ArrayAccess':
		return CompileArrayAccess(node)
	elif node.type == 'String':
		return CompileString(node)
	elif node.type == 'Dereference':
		return CompileDereference(node)
	elif node.type == 'Addr':
		return CompileAddr(node)
	elif node.type == 'Number':
		return CompileNumber(node)
	elif node.type == 'TypeCast':
		return CompileTypecast(node)

def CompileTypecast(node):
	t = node.value
	CompileExpression(node.children[0])
	return t

def CompileTernaryOp(node):
	L1 = cg.NewLabel()
	L2 = cg.NewLabel()
	CompileFalseCondition(node.children[0], L2)
	CompileExpression(node.children[1])
	cg.BranchTo(L1)
	cg.PutLabel(L2)
	CompileExpression(node.children[2])
	cg.PutLabel(L1)
	
	return ctypes.NumberType(size=4)

def CompileBinaryOp(node):
	if node.value == '+':
		return CompileAdd(node)
	elif node.value == '-':
		return CompileSub(node)
	elif node.value == '*':
		return CompileMul(node)
	elif node.value == '/':
		return CompileDiv(node)
	elif node.value == '%':
		return CompileMod(node)
	elif node.value == '<<':
		return CompileShl(node)
	elif node.value == '>>':
		return CompileShr(node)
	return CompileBinaryOpX(node)
	
	# TODO: finish implementing them
	if node.value == '&&':
		return CompileAnd(node)
	elif node.value == '&':
		return CompileBitwiseAnd(node)
	elif node.value == '||':
		return CompileOr(node)
	elif node.value == '|':
		return CompileBitwiseOr(node)
	elif node.value == '^':
		return CompileXor(node)

def CompileAdd(node):
	if node.children[0].type == 'Number':
		t = CompileExpression(node.children[1])
		cg.AddMainVal(node.children[0].value)
	elif node.children[1].type == 'Number':
		t = CompileExpression(node.children[0])
		cg.AddMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.AddMainStackTop()
	return ctypes.NumberType(size=4)

def CompileSub(node):
	if node.children[0].type == "Number":
		t = CompileExpression(node.children[1])
		cg.SubMainVal(node.children[0].value)
		cg.NegMain()
	elif node.children[1].type == "Number":
		t = CompileExpression(node.children[0])
		cg.SubMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.SubMainStackTop()
	return ctypes.NumberType(size=4)

def CompileMul(node):
	if node.children[0].type == "Number":
		t = CompileExpression(node.children[1])
		cg.MulMainVal(node.children[0].value)
	elif node.children[1].type == "Number":
		t = CompileExpression(node.children[0])
		cg.MulMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.MulMainStackTop()
	return ctypes.NumberType(size=4)

def CompileDiv(node):
	if node.children[1].type == "Number":
		t = CompileExpression(node.children[0])
		cg.DivMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.DivMainStackTop()
	return ctypes.NumberType(size=4)

def CompileMod(node):
	if node.children[1].type == "Number":
		t = CompileExpression(node.children[0])
		cg.ModMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.ModMainStackTop()
	return ctypes.NumberType(size=4)

def CompileShr(node):
	if node.children[0].type == "Number":
		t = CompileExpression(node.children[1])
		cg.ShrValMain(node.children[0].value)
	elif node.children[1].type == "Number":
		t = CompileExpression(node.children[0])
		cg.ShrMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.ShrMainStackTop()
	return ctypes.NumberType(size=4)

def CompileShl(node):
	if node.children[0].type == 'Number':
		t = CompileExpression(node.children[1])
		cg.ShlValMain(node.children[0].value)
	elif node.children[1].type == 'Number':
		t = CompileExpression(node.children[0])
		cg.ShlMainVal(node.children[1].value)
	else:
		t1 = CompileExpression(node.children[0])
		cg.PushMain()
		t2 = CompileExpression(node.children[1])
		cg.ShlMainStackTop()
	return ctypes.NumberType(size=4)

def CompileBinaryOpX(node):
	t1 = CompileExpression(node.children[0])
	cg.PushMain()
	t2 = CompileExpression(node.children[1])
	if node.value == "&&":
		cg.AndMainStackTop() # TODO: make it lazy
	elif node.value == "&":
		cg.AndMainStackTop()
	elif node.value == "||":
		cg.OrMainStackTop() # TODO: make it lazy
	elif node.value == "|":
		cg.OrMainStackTop()
	elif node.value == "^":
		cg.XorMainStackTop()
	return ctypes.NumberType(size=4)

# Only unsigned comparisons are supported right now
def CompileRelation(node):
	if node.children[1].type == "Number":
		CompileExpression(node.children[0])
		cg.CompareMainVal(node.children[1].value)
	elif node.children[0].type == "Number":
		CompileExpression(node.children[1])
		cg.CompareValMain(node.children[0].value)
	else:
		CompileExpression(node.children[0])
		cg.PushMain()
		CompileExpression(node.children[1])
		cg.CompareStackTopMain()
	
	if node.value == "==":
		cg.SetIfEqual()
	elif node.value == "!=":
		cg.SetIfNotEqual()
	elif node.value == "<=":
		cg.SetIfLessOrEqual()
	elif node.value == ">=":
		cg.SetIfAboveOrEqual()
	elif node.value == ">":
		cg.SetIfAbove()
	elif node.value == "<":
		cg.SetIfLess()
	
	if node.children[0].type != "Number" and node.children[1].type != "Number":
		cg.StackFree(1)
	
	return ctypes.NumberType(size=1)

def CompileSingleRelation(node):
	if node.children[1].type == 'Number':
		CompileExpression(node.children[0])
		cg.CompareMainVal(node.children[1].value)
	elif node.children[0].type == 'Number':
		CompileExpression(node.children[1])
		cg.CompareValMain(node.children[0].value)
	else:
		CompileExpression(node.children[0])
		cg.PushMain()
		CompileExpression(node.children[1])
		cg.CompareStackTopMain()
	
	if node.children[0].type != 'Number' and node.children[1].type != 'Number':
		cg.StackFree(1)
	
	return ctypes.NumberType(size=1)

def CompilePrefixUnaryOp(node):
	if node.value == '!':
		t = CompileExpression(node.children[0])
		cg.LogicalNotMain()
		return t
	elif node.value == '~':
		t = CompileExpression(node.children[0])
		cg.NotMain()
		return t
	else:
		t = CompileVariableRead(node.children[0])
		if node.value == '++':
			cg.IncrementMain()
		elif node.value == '--':
			cg.DecrementMain()
		CompileStore(node.children[0])
		return t

def CompilePostfixUnaryOp(node):
	t = CompileVariableRead(node.children[0])
	cg.PrimaryToSecondary()
	if node.value == '++':
		cg.IncrementMain()
	elif node.value == '--':
		cg.DecrementMain()
	CompileStore(node.children[0])
	cg.SecondaryToPrimary()
	return t

def CompileStatementPrefixUnaryOp(node): # TODO: Get better codegen to optimize this
	if node.value == '!':
		t = CompileExpression(node.children[0])
		cg.LogicalNotMain()
		return t
	elif node.value == '~':
		t = CompileExpression(node.children[0])
		cg.NotMain()
		return t
	else:
		t = CompileVariableRead(node.children[0])
		if node.value == '++':
			cg.IncrementMain()
		elif node.value == '--':
			cg.DecrementMain()
		CompileStore(node.children[0])
		return t

def CompileStatementPostfixUnaryOp(node):
	t = CompileVariableRead(node.children[0])
	if node.value == "++":
		cg.IncrementMain()
	elif node.value == "--":
		cg.DecrementMain()
	CompileStore(node.children[0])
	return t

def CompileAssignement(node):
	if not node.children[0].type in ['Variable', 'Dereference', 'ArrayAccess', 'StructMemberAccess', 'StructPointerMemberAccess']:
		abort('Cannot assign to something else than a variable')
	if node.value == '=':
		t = CompileExpression(node.children[1])
		t2 = CompileStore(node.children[0])
		if not CanCastImplicitly(t, t2):
			abort('Incompatible types')
	else:
		CompileExpression(node.children[0])
		cg.PushMain()
		t = CompileExpression(node.children[1])
		if node.value == '+=':
			cg.AddMainStackTop()
		elif node.value == '-=':
			cg.SubMainStackTop()
		elif node.value == '*=':
			cg.MulMainStackTop()
		elif node.value == '/=':
			cg.DivMainStackTop()
		elif node.value == '>>=':
			cg.ShrMainStackTop()
		elif node.value == '<<=':
			cg.ShlMainStackTop()
		elif node.value == '&=':
			cg.AndMainStackTop()
		elif node.value == '|=':
			cg.OrMainStackTop()
		elif node.value == '^=':
			cg.XorMainStackTop()
		t2 = CompileStore(node.children[0])
		if not CanCastImplicitly(t, t2):
			abort('Incompatible types')
	return t

# TODO: avoid storing to const, also I'm pretty sure it can be made much, much simpler by just loading the address and then dereferencing
def CompileStore(node):
	# This may be either a variable, a dereference, a struct member access or a struct pointer member access
	if node.type == 'Variable':
		name = node.value
		d = ident_ST.get_symbol_value(name)
		if not d:
			Undefined(name)
		t = d['type']
		
		if ident_ST.is_symbol_global(name):
			cg.StoreToGlobalVariable(name, t.size)
		else:
			offset = ident_ST.get_symbol_offset(name)
			cg.StoreToLocalVariable(offset * 4, t.size)
		return t
	elif node.type == 'Dereference':
		cg.PushMain()
		t = CompileExpression(node.children[0])
		
		if not isinstance(t, ctypes.PointerType):
			abort('Undereferencable expression (not a pointer)')
		
		cg.StoreDereferenceMain(t.arg.size)
		return t.arg
	elif node.type == 'StructMemberAccess':
		abort('not implemented yet (Maybe use a struct pointer ?)') # TODO: do
	elif node.type == 'StructPointerMemberAccess':
		cg.PushMain()
		
		name = node.value
		member_name = node.children[0].value
		d = ident_ST.get_symbol_value(name)
		if not d:
			Undefined(name)
		s_t = d['type']
		if not isinstance(s_t, ctypes.PointerType):
			abort(name + ' is not a pointer')
		
		struct_name = s_t.arg.name
		
		o = 0
		found = False
		for m in struct_ST.get_symbol_value(struct_name):
			if m.value['name'] == member_name:
				found = True
				t = m.value['type']
				break
			o += m.value['type'].size
		if not found:
			abort('struct ' + struct_name + " doesn't have a member " + member_name)
	
		if ident_ST.is_symbol_global(name):
			cg.LoadGlobalVariable(name, s_t.size)
			return t
		else:
			offset = ident_ST.get_symbol_offset(name)
			cg.LoadLocalVariable(offset * 4, s_t.size)
		
		if o:
			cg.AddMainVal(o)
		
		cg.StoreDereferenceMain(t.size)
		
		return t
	elif node.type == 'ArrayAccess':
		name = node.value
		if not ident_ST.symbol_exists(name):
			Undefined(name)
		t2 = ident_ST.get_symbol_value(name)['type']
		if not isinstance(t2, ctypes.ArrayType):
			abort('not array type is not subscriptable')
		cg.PushMain()
		if ident_ST.is_symbol_global(name):
			cg.LoadGlobalIdentifierAddress(name)
		else:
			offset = ident_ST.get_symbol_offset(name)
			cg.LoadLocalVariableAddress((offset -  1) * 4 + t2.len * t2.arg.size)
		cg.PushMain()
		t = CompileExpression(node.children[0])
		if not CanCastImplicitly(t, ctypes.NumberType(size=4)):
			abort('Cannot index array with something else than int')
		if t2.arg.size != 1:
			cg.MulMainVal(t2.arg.size)
		cg.AddMainStackTop()
		cg.StoreDereferenceMain(t2.arg.size)
		return t2.arg


def CompileNumber(node):
	cg.LoadNumber(node.value)
	return ctypes.NumberType(size=4)

def CompileString(node):
	if not string_ST.symbol_exists(node.value):
		L = cg.NewLabel()
		cg.EmitLnData(FormatString(L, node.value))
		string_ST.add_symbol(node.value, L)
	else:
		L = string_ST.get_symbol_value(node.value)
	cg.LoadLabel(L)
	return ctypes.PointerType(arg=ctypes.NumberType(size=1))

def CompileVariableRead(node):
	name = node.value
	
	d = ident_ST.get_symbol_value(name)
	if not d:
		Undefined(name)
	t = d['type']
	
	if ident_ST.is_symbol_global(name):
		if isinstance(t, ctypes.StructType):
			abort('Cannot load structured type here')
		if isinstance(t, ctypes.FunctionType):
			cg.LoadGlobalIdentifierAddress(name)
			return ctypes.PointerType(arg=t, const=False) # Decay to func pointer
		cg.LoadGlobalVariable(name, t.size)
		return t
	else:
		if isinstance(t, ctypes.StructType):
			abort('Cannot load structured type here')
		offset = ident_ST.get_symbol_offset(name)
		cg.LoadLocalVariable(offset * 4, t.size)
		return t

def CompileFunctionCall(node):
	name = node.value
	d = ident_ST.get_symbol_value(name)
	if d == None:
		Undefined(name)
	for a in d['attributes']:
		if not a.vendor and a.name == 'deprecated':
			warning(f'Function {name} is deprecated for the reason: {a.arguments[0]}')
	t = d['type']
	
	if isinstance(t, ctypes.FunctionType):
		arg_list = t.args
		i = len(arg_list) - 1
		call_args = node.children[0].children
		call_args.reverse() # We use cdecl, so arguments are pushed in reverse
		
		for child in call_args:
			arg_type = CompileExpression(child)
			if i >= 0:
				if arg_type != arg_list[i]['type'] and not CanCastImplicitly(arg_type, arg_list[i]['type']):
					abort(f'wrong type of argument {i} while calling {name}')
			cg.PushMain()
			i -= 1
		
		call_args.reverse() # Re-reverse so we can re-use the values, though idk if we ever do that. Stupid in-place function.
		
		if len(call_args) != len(t.args) and not Attribute(vendor='roverc', name='varargs') in d['attributes']:
			abort("wrong number of arguments while calling " + name + ": " + str(len(call_args)) + " instead of " + str(len(t.args)))
		cg.CallFunction(name)
		
		if len(t.args) != 0 and not Attribute(name='__stdcall') in d['attributes']:
			cg.StackFree(len(t.args))
		
		return t.ret
	elif isinstance(t, ctypes.PointerType) and isinstance(t.arg, ctypes.FunctionType):
		if ident_ST.is_symbol_global(name):
			cg.LoadGlobalVariable(name, 4)
		else:
			offset = ident_ST.get_symbol_offset(name)
			cg.LoadLocalVariable(offset * 4, 4)
		cg.CallMain()
		return t.arg.ret
	else:
		abort('uncallable identifier (' + name + ')')

def CompileDereference(node):
	t = CompileExpression(node.children[0])
	
	if not isinstance(t, ctypes.PointerType):
		abort('Undereferencable expression (not a pointer)')
	
	cg.DereferenceMain(t.arg.size)
	return t.arg

def CompileAddr(node):
	n2 = node.children[0]
	if not n2.type in ['Variable', 'StructMemberAccess', 'StructPointerMemberAccess', 'ArrayAccess']:
		abort('Cannot compute address of an expression without an address')
	if n2.type == 'Variable':
		name = n2.value
		
		d = ident_ST.get_symbol_value(name)
		if not d:
			Undefined(name)
		t = d['type']
		
		if ident_ST.is_symbol_global(name):
			cg.LoadGlobalIdentifierAddress(name)
			return ctypes.PointerType(arg=t)
		else:
			offset = ident_ST.get_symbol_offset(name)
			cg.LoadLocalIdentifierAddress(offset * 4)
			return ctypes.PointerType(arg=t)
	else:
		abort('not implemented') # TODO: do

def CompileStructMemberAccess(node):
	identifier_name = node.value
	d = ident_ST.get_symbol_value(identifier_name)
	if not d:
		Undefined(identifier_name)
	t = d['type']
	if not isinstance(t, ctypes.PointerType):
		abort("Cannot access the members of a pointer on struct with '.'")
	struct_name = t.arg
	abort("not implemented yet") # TODO: do

def CompileStructPointerMemberAccess(node):
	name = node.value
	d = ident_ST.get_symbol_value(name)
	if not d:
		Undefined(name)
	t = d['type']
	if not isinstance(t, ctypes.PointerType):
		abort("Cannot access the members of a struct with '->'")
	if not isinstance(t.arg, ctypes.StructType):
		abort("Cannot use operator '->' with something else than a struct pointer")
	struct_name = t.arg.name
	member_name = node.children[0].value
	
	o = 0
	found = False
	for m in struct_ST.get_symbol_value(struct_name):
		if m.value['name'] == member_name:
			found = True
			member_t = m.value['type']
			break
		o += m.value['type'].size
	if not found:
		abort('struct ' + struct_name + " doesn't have a member " + member_name)
	
	if isinstance(member_t, ctypes.StructType):
		abort("not implemented yet") # TODO: do
	else:
		CompileVariableRead(node)
		cg.AddMainVal(o)
		cg.DereferenceMain(member_t.size)
		return member_t

def CompileArrayAccess(node):
	name = node.value
	if not ident_ST.symbol_exists(name):
		Undefined(name)
	t2 = ident_ST.get_symbol_value(name)['type']
	if not isinstance(t2, ctypes.ArrayType):
		abort('not array type is not subscriptable')
	if ident_ST.is_symbol_global(name):
		cg.LoadGlobalIdentifierAddress(name)
	else:
		offset = ident_ST.get_symbol_offset(name)
		cg.LoadLocalVariableAddress((offset -  1) * 4 + t2.len * t2.arg.size)
	cg.PushMain()
	t = CompileExpression(node.children[0])
	if not CanCastImplicitly(t, ctypes.NumberType(size=4)):
		abort('Cannot index array with something else than int')
	if t2.arg.size != 1:
		cg.MulMainVal(t2.arg.size)
	cg.AddMainStackTop()
	cg.DereferenceMain(t2.arg.size)
	return t2.arg
