"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: A file containing the symbol table data structure, and a set of setters and getters functions
"""

from core.helpers import *

# Data structure
class SymbolTable:
	def __init__(self):
		self.identifiers = IdentifiersSymbolTable()
		self.structs = StructsSymbolTable()

class StructsSymbolTable:
	def __init__(self):
		self.elements = [] # An array of Struct()

class Struct:
	def __init__(self, name, member_dict_arr, size):
		self.name = name
		self.members = member_dict_arr
		self.size = size

class IdentifiersSymbolTable:
	def __init__(self):
		self.elements = [] # An array of Identifier()

class Identifier:
	def __init__(self, name, type_, args=None, is_global=False, stack_offset=0, is_variable=False, is_function=False):
		self.name = name
		self.is_variable = is_variable
		self.is_function = is_function
		self.type = type_
		self.arguments = args
		self.is_global = is_global
		self.stack_offset = stack_offset


# Helpers
def IsNameTaken(name):
	if IsKeyword(name):
		return True
	
	for ident in symtable.identifiers.elements:
		if ident.name == name:
			return True
	for struct in symtable.identifiers.elements:
		if struct.name == name:
			return True
	
	return False


# Setters
def AddFunction(name, t, args):
	if IsNameTaken(name):
		abort("name redefinition (" + name + ")")
	symtable.identifiers.elements.append(Identifier(name, t, args=args, is_function=True))

def AddVariable(name, t, is_global=False, stack_offset=0):
	if IsNameTaken(name):
		abort("name redefinition (" + name + ")")
	symtable.identifiers.elements.append(Identifier(name, t, is_global=is_global, is_variable=True, stack_offset=stack_offset))

def AddStruct(name, members):
	if IsNameTaken(name):
		abort("name redefinition (" + name + ")")
	size = 0
	for m in members:
		if m["type"].pointer_level != 0:
			size += 4
		else:
			size += SizeOf(m["type"].datatype)
	symtable.structs.elements.append(Struct(name, members, size))

def DeleteLocalVariables():
	i = 0
	while i < len(symtable.identifiers.elements):
		if not symtable.identifiers.elements[i].is_global and symtable.identifiers.elements[i].is_variable:
			del symtable.identifiers.elements[i]
		else:
			i += 1


# Getters
def IsVariable(name):
	for n in symtable.identifiers.elements:
		if not n.is_variable:
			continue
		if n.name == name:
			return True
	return False

def IsFunction(name):
	for n in symtable.identifiers.elements:
		if not n.is_function:
			continue
		if n.name == name:
			return True
	return False

def IsStruct(n):
	for n in symtable.structs.elements:
		if n.name == name:
			return True
	return False

def SizeOf(n):
	if IsBuiltInType(n):
		return SizeOfBuiltIn(n)
	else:
		for s in symtable.structs.elements:
			if s.name == n:
				return s.size
		return 0

def GetFunctionType(name):
	for n in symtable.identifiers.elements:
		if not n.is_function:
			continue
		if n.name == name:
			return n.type
	return None

def GetFunctionArgCount(name):
	for n in symtable.identifiers.elements:
		if not n.is_function:
			continue
		if n.name == name:
			return len(n.arguments)
	return None

def GetFunctionArgType(name):
	for n in symtable.identifiers.elements:
		if not n.is_function:
			continue
		if n.name == name:
			type_list = []
			for a in n.arguments:
				type_list.append(a["type"])
			return type_list
	return []

def GetVariableType(name):
	for n in symtable.identifiers.elements:
		if not n.is_variable:
			continue
		if n.name == name:
			return n.type
	return None

def IsVariableGlobal(name):
	for n in symtable.identifiers.elements:
		if not n.is_variable:
			continue
		if n.name == name:
			return n.is_global
	return False

def GetLocalVariableOffset(name):
	for n in symtable.identifiers.elements:
		if not n.is_variable:
			continue
		if n.name == name:
			return n.stack_offset
	return 0

def IsStructMember(struct, name):
	for s in symtable.structs.elements:
		if s.name == struct:
			for m in s.members:
				if m["name"] == name:
					return True
	return False

def GetMemberType(struct, name):
	for s in symtable.structs.elements:
		if s.name == struct:
			for m in s.members:
				if m["name"] == name:
					return m["type"]
	return None



def Dump():
	print("\n==========================================")
	print("STRUCTURES\n")
	for s in symtable.structs.elements:
		print("New struct: ",s.name)
		print("  members:  ")
		for m in s.members:
			print("    ",m)
		print("  size:     ",s.size)
	print("\n==========================================")
	print("VARIABLES\n")
	for v in symtable.identifiers.elements:
		if not v.is_variable:
			continue
		print("New variable: ",v.name)
		print("  type:       ",v.type)
		print("  scope:      ",v.scope)
	print("\n==========================================")
	print("FUNCTIONS\n")
	for v in symtable.identifiers.elements:
		if not v.is_function:
			continue
		print("New function: ",v.name)
		print("  type:       ",v.type)
		print("  args:       ",v.arguments)

symtable = SymbolTable()
