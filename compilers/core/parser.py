"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The third stage of the compiler, that takes a preprocessed stream of tokens and outputs an AST
"""

TEST_MODE = False
last_err = ''

import sys

from core.helpers import *

AST = None
token_stream = None

streampos = -1
token = ""
value = ""

file_name = ""
line_number = 0
character_number = 0


# Error functions
def abort(s):
	global last_err
	
	if TEST_MODE:
		last_err = s
		raise TestModeError
	
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit(-1)

def Expected(s):
	abort("Expected " + s)



class ASTNode:
	def __init__(self, type_, children=None, value=None):
		self.type = type_
		self.children = children or []
		self.value = value

	def __repr__(self):
		return f"ASTNode(type='{self.type}', value='{self.value}', children={self.children})"
	
	def __eq__(self, other):
		return type(self) == type(other) and self.type == other.type and self.children == other.children and self.value == other.value


def Next():
	global token_stream, streampos, token, value, file_name, line_number, character_number

	streampos += 1
	
	if streampos >= len(token_stream):
		new_token = token_stream[-1]
	else:
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def ReloadToken():
	global token_stream, token, value, file_name, line_number, character_number

	if streampos >= len(token_stream):
		new_token = token_stream[-1]
	else:
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token


def Previous():
	global token_stream, streampos, token, value, file_name, line_number, character_number

	streampos -= 1

	if streampos >= len(token_stream):
		new_token = token_stream[-1]
	else:
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token


def MatchString(t):
	if value == t:
		Next()
	else:
		Expected(t)



def ProduceAST():
	global AST
	
	Next()
	AST = ASTNode(type_="Program",children=[])
	
	while token != "\0":
		if value == "struct":
			AST.children.append(StructDecl())
		else:
			AST.children.append(GlobalIdentifier())

	# Return the AST
	return AST

def StructDecl():
	MatchString("struct")
	name = value
	node = ASTNode(type_="StructDecl", value=name, children=[])
	Next()
	
	MatchString("{")
	while token != "}":
		t = ParseType()
		n = value
		Next()
		node.children.append({"name":n,"type":t})
		while token == ",":
			Next()
			n = value
			Next()
			node.children.append({"name":n,"type":t})
		MatchString(";")
	MatchString("}")
	
	return node

def GlobalIdentifier():
	global streampos
	
	old_streampos = streampos
	ParseC23Attributes() if token == "[" else ()
	ParseType()
	ParseCallingConvention() if value in calling_conventions else ()
	Next()
	if token == "(":
		streampos = old_streampos
		ReloadToken()
		return Function()
	else:
		streampos = old_streampos
		ReloadToken()
		return GlobalVariable()

def GlobalVariable():
	t = ParseType()
	name = value
	Next()
	if token == "=":
		Next()
		node = ASTNode(type_="GlobalDecl",value={"name":name,"type":t},children=[e])
	else:
		node = ASTNode(type_="GlobalDecl",value={"name":name,"type":t})
	MatchString(";")
	return node

def Function():
	# Attributes (C23)
	c23_function_attributes = ParseC23Attributes() if token == "[" else []
	
	# Type (standard)
	function_type = ParseType()
	
	# Calling convention (MSVC)
	msvc_function_attributes = ParseCallingConvention() if value in calling_conventions else [Attribute(name='__cdecl')] # Functions use cdecl by default
	
	# Name (standard)
	function_name = value
	
	# Attributes (GCC)
	function_attributes = []
	Next()
	arg_list = ArgumentList()
	gcc_function_attributes = ParseGccAttributes() if value == "__attribute__" else []
	
	function_attributes.extend(c23_function_attributes)
	function_attributes.extend(gcc_function_attributes)
	function_attributes.extend(msvc_function_attributes)
	
	# Function body (standard)
	if token == ";":
		node = ASTNode(type_="FunctionDeclaration",value={"name":function_name,"type":function_type},children=[function_attributes,arg_list])
		MatchString(";")
	else:
		node = ASTNode(type_="Function",value={"name":function_name,"type":function_type},children=[function_attributes,arg_list,Block()])
	
	return node

def ArgumentList():
	MatchString("(")
	node = ASTNode(type_="ArgumentList",children=[])
	
	if value == "void":
		Next()
	elif token != ")":
		node.children.append(Argument())
		
		while token == ",":
			MatchString(",")
			node.children.append(Argument())
	
	MatchString(")")
	
	return node

def Argument():
	arg_type = ParseType()
	arg_name = value
	Next()
	
	return {"name":arg_name, "type":arg_type}

def ParseType():
	pointer_level = 0
	
	if value == "struct":
		Next()
	t = value
	Next()
	
	while token == "*":
		pointer_level += 1
		Next()
	
	return Type_(t,pointer_level)

def ParseAttribute():
	attr_name = value
	vendor = ""
	arguments = []
	Next()
	if token == ":":
		vendor = attr_name
		MatchString(":")
		MatchString(":")
		attr_name = value
		Next()
	
	if token == "(":
		abort("attribute arguments aren't implemented yet")
	
	return Attribute(vendor=vendor, name=attr_name, arguments=arguments)

def ParseC23Attributes():
	
	attributes = []
	
	while token == "[":
		MatchString("[")
		MatchString("[")
		
		if token != "]":
			attributes.append(ParseAttribute())
		
		while token == ",":
			MatchString(",")
			attributes.append(ParseAttribute())
		
		MatchString("]")
		MatchString("]")
	
	return attributes

def ParseGccAttributes():
	attributes = []
	
	while value == "__attribute__":
		MatchString("__attribute__")
		MatchString("(")
		MatchString("(")
		
		if token != ")":
			attributes.append(ParseAttribute())
		
		while token == ",":
			MatchString(",")
			attributes.append(ParseAttribute())
		
		MatchString(")")
		MatchString(")")
	
	return attributes

def ParseCallingConvention():
	if not value in calling_conventions:
		Expected('Calling convention name (Ex: __cdecl)')
	name = value
	Next()
	return [Attribute(name=name)]

def Block():
	MatchString("{")
	node = ASTNode(type_="Block")
	while token != "}":
		Statement(node)
	
	MatchString("}")
	return node

def Case():
	node = ASTNode(type_="Block")
	while token != "}" and value != "case" and value != "default":
		Statement(node)
	return node

def Statement(node):
	if token == ";":
		MatchString(";")
	elif value == "if":
		node.children.append(If())
	elif value == "while":
		node.children.append(While())
	elif value == "for":
		node.children.append(For())
	elif value == "switch":
		node.children.append(Switch())
	elif token == "{":
		node.children.append(Block())
	elif value == "return":
		node.children.append(Return())
		MatchString(";")
	elif value == "asm":
		node.children.append(Asm())
		MatchString(";")
	elif value == "break":
		node.children.append(Break())
		MatchString(";")
	elif value == "continue":
		node.children.append(Continue())
		MatchString(";")
	elif value == "struct" or IsBuiltInType(value):
		node.children.extend(LocDecl())
		MatchString(";")
	else:
		node.children.append(Expression())
		MatchString(";")

def If():
	node = ASTNode(type_="ControlStructure",value="IF",children=[])
	MatchString("if")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	node.children.append(Block())
	while value == "else":
		Next()
		if value != "if":
			Previous()
			break
		Next()
		MatchString("(")
		elseif_node = ASTNode(type_="ControlStructure",value="ELSEIF",children=[Expression()])
		MatchString(")")
		elseif_node.children.append(Block())
		node.children.append(elseif_node)
	if value == "else":
		Next()
		else_node = ASTNode(type_="ControlStructure",value="ELSE",children=[Block()])
		node.children.append(else_node)
	return node

def While():
	node = ASTNode(type_="ControlStructure",value="WHILE",children=[])
	MatchString("while")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	node.children.append(Block())
	return node

def For():
	node = ASTNode(type_="ControlStructure",value="FOR",children=[])
	MatchString("for")
	MatchString("(")
	node.children.append(ASTNode(type_="Number", value="1")) if token == ";" else node.children.extend(LocDecl()) if value == "struct" or IsBuiltInType(value) else node.children.append(Expression())
	MatchString(";")
	node.children.append(ASTNode(type_="Number", value="1")) if token == ";" else node.children.append(Expression())
	MatchString(";")
	node.children.append(ASTNode(type_="Number", value="0")) if token == ")" else node.children.append(Expression())
	MatchString(")")
	node.children.append(Block())
	return node

def Switch():
	node = ASTNode(type_="ControlStructure", value="SWITCH", children=[])
	MatchString("switch")
	MatchString("(")
	node.children.append(Expression())
	node.children.append([])
	MatchString(")")
	MatchString("{")
	while value == "case":
		MatchString("case")
		
		if token != '0':
			Expected('numeric litteral')
		node.children[1].append(Factor())
		
		MatchString(":")
		
		node.children.append(Case())
	if value == "default":
		MatchString("default")
		MatchString(":")
		
		node.children[1].append(None)
		node.children.append(Case())
	MatchString("}")
	
	return node

def Return():
	node = ASTNode(type_="ControlStructure",value="RETURN",children=[])
	MatchString("return")
	node.children.append(Expression())
	return node

def Asm():
	node = ASTNode(type_="ControlStructure",value="ASM",children=[])
	MatchString("asm")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	return node

def Break():
	MatchString("break")
	return ASTNode(type_="ControlStructure",value="BREAK")

def Continue():
	MatchString("continue")
	return ASTNode(type_="ControlStructure",value="CONTINUE")

def LocDecl():
	t = ParseType()
	node_array = []
	
	name = value
	node = ASTNode(type_="LocDecl",value={"name":name,"type":t},children=[])
	Next()
	if token == "=":
		Next()
		node.children = [Expression()]
	node_array.append(node)
	
	while token == ",":
		Next()
		name = value
		node = ASTNode(type_="LocDecl",value={"name":name,"type":t},children=[])
		Next()
		if token == "=":
			Next()
			node.children = [Expression()]
		node_array.append(node)
	
	return node_array

def Expression():
	return AssignExpression()

def ExpressionLevel(successor, node_type="BinaryOp", token_set=None, token_getter=None, next_token_predicate=None):
	node = successor()
	
	if token_set:
		while token in token_set:
			op = token
			Next()
			
			if next_token_predicate and not next_token_predicate(op,token):
				Previous()
				break
			
			right = successor()
			node = ASTNode(type_=node_type,children=[node,right],value=op)
	else:
		op_sequence = token_getter()
		while op_sequence != "":
			
			if next_token_predicate and not next_token_predicate(op_sequence,token):
				for i in range(len(op_sequence)):
					Previous() # these are operators, not words or digits
				break
			
			right = successor()
			node = ASTNode(type_=node_type,children=[node,right],value=op_sequence)
			
			op_sequence = token_getter()
	return node

def AssignementSequence():
	if token == "=":
		Next()
		if token == "=": # Backtrack, we're in a relation
			Previous()
			return ""
		return "="
	elif token in ["-","+","/","%","*","|","^","&"]:
		first_token = token
		Next()
		if token != "=":
			Previous()
			return ""
		Next()
		return first_token + "="
	elif token == "<" or token == ">":
		first_token = token
		Next()
		if token != first_token:
			Previous()
			return ""
		first_token += token
		Next()
		if token != "=":
			Previous()
			Previous()
			return ""
		Next()
		return first_token + "="
	return ""

def AssignExpression():
	return ExpressionLevel(TernaryOp, node_type="Assignement", token_getter=AssignementSequence)

def TernaryOp():
	node = BoolTerm()
	if token == ":":
		MatchString(":")
		result1 = BoolTerm()
		MatchString("?")
		result2 = BoolTerm()
		node = ASTNode(type_="TernaryOp",children=[node,result1,result2])
	return node

def LogicalOrSequence():
	if token == "|":
		Next()
		if token == "|":
			Next()
			return "||"
		Previous()
	return ""

def BoolTerm():
	return ExpressionLevel(AndTerm, token_getter=LogicalOrSequence)

def LogicalAndSequence():
	if token == "&":
		Next()
		if token == "&":
			Next()
			return "&&"
		Previous()
	return ""

def AndTerm():
	return ExpressionLevel(BitwiseOr, token_getter=LogicalAndSequence)

def BitwiseOr():
	def next_token_predicate(op,token):
		return token != "|"
	return ExpressionLevel(BitwiseXor, token_set={"|"},next_token_predicate=next_token_predicate)

def BitwiseXor():
	return ExpressionLevel(BitwiseAnd, token_set={"^"})

def BitwiseAnd():
	def next_token_predicate(op,token):
		return token != "&"
	return ExpressionLevel(Relation, token_set={"&"},next_token_predicate=next_token_predicate)

def RelationSequence():
	if token == "=":
		Next()
		if token != "=":
			Previous()
			return ""
		Next()
		return "=="
	elif token == "<":
		Next()
		if token == "=":
			Next()
			return "<="
		return "<"
	elif token == ">":
		Next()
		if token == "=":
			Next()
			return ">="
		return ">"
	elif token == "!":
		Next()
		if token != "=":
			Previous()
			return ""
		Next()
		return "!="
	return ""

def Relation():
	return ExpressionLevel(BitwiseFactor, node_type="Relation", token_getter=RelationSequence)

def ShiftSequence():
	if token == ">":
		Next()
		if token == ">":
			Next()
			return ">>"
		Previous()
	elif token == "<":
		Next()
		if token == "<":
			Next()
			return "<<"
		Previous()
	return ""

def BitwiseFactor():
	def next_token_predicate(op, token):
		return token != "="
	return ExpressionLevel(NumericExpression,token_getter=ShiftSequence,next_token_predicate=next_token_predicate)

def NumericExpression():
	def next_token_predicate(op, token):
		return token != "=" and token != op
	return ExpressionLevel(Term, token_set={"+","-"},next_token_predicate=next_token_predicate)

def Term():
	def next_token_predicate(op, token):
		return token != "="
	return ExpressionLevel(UnaryFactor, token_set={"*","/","%"},next_token_predicate=next_token_predicate)

def IncSequence():
	if token == "+":
		Next()
		if token == "+":
			Next()
			return "++"
		Previous()
	elif token == "-":
		Next()
		if token == "-":
			Next()
			return "--"
		Previous()
	return ""

def UnaryFactor():
	inc_sequence = IncSequence()
	if inc_sequence != "":
		node = ASTNode(type_="PrefixUnaryOp",value=inc_sequence,children=[Factor()])
	else:
		node = Factor()
	
	inc_sequence = IncSequence()
	if inc_sequence != "":
		return ASTNode(type_="PostfixUnaryOp",value=inc_sequence,children=[node])
	return node

def ArgumentListCall():
	node = ASTNode(type_="ArgumentListCall", value=None, children=[])
	if token != ")":
		node.children.append(Expression())
		while token == ",":
			Next()
			node.children.append(Expression())
	return node

def Factor():
	global value
	
	# Parse a numeric literal or handle parentheses for subexpressions
	if IsAddop(token):
		if token == "-":
			Next()
			value = "-" + value
		else:
			Next() # The token is '+'
	
	if token == "0":
		if value[-1] == "h":
			int_val = int(value[:-1],16)
		else:
			int_val = int(value)
		node = ASTNode(type_="Number", value=int_val)
		Next()
	elif token == "!":
		MatchString("!")
		return ASTNode(type_="PrefixUnaryOp", value="!", children=[Expression()])
	elif token == "x":
		name = value
		Next()
		if token == "(":
			Next()
			node = ASTNode(type_="FunctionCall", value=name, children=[ArgumentListCall()])
			MatchString(")")
		elif token == ".":
			Next()
			node = ASTNode(type_="StructMemberAccess", value=name, children=[Factor()])
		elif token == "-": # Maybe a struct pointer member access
			Next()
			if token != ">": # Nope
				Previous()
				node = ASTNode(type_="Variable", value=name)
			else:
				Next()
				node = ASTNode(type_="StructPointerMemberAccess", value=name, children=[Factor()])
		else:
			node = ASTNode(type_="Variable", value=name)
	elif token == "*":
		Next()
		node = ASTNode(type_="Dereference", children=[Factor()])
	elif token == "s":
		node = ASTNode(type_="String", value=value)
		Next()
	elif token == "(":
		Next()
		node = Expression()
		MatchString(")")
	else:
		Expected("factor")
	
	return node
