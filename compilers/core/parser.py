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
import core.ctypes as ctypes
import core.symboltable as st
import core.optimizer as opt

AST = None
token_stream = None

streampos = -1
token = ""
value = ""

file_name = ""
line_number = 0
character_number = 0

ST = st.SymbolTable()


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
	
	while token != '\0':
		AST.children += Decl()

	# Return the AST
	return AST

def ParseAttribute():
	attr_name = value
	vendor = ''
	arguments = []
	Next()
	if token == ':':
		vendor = attr_name
		MatchString(':')
		MatchString(':')
		attr_name = value
		Next()
	
	if token == '(':
		MatchString('(')
		
		while token != ')':
			if token != 'x' and token != '0' and token != 's':
				Expected('symbol, number or string')
			arguments.append(value)
			Next()
			
			if token != ')':
				MatchString(',')
		
		MatchString(')')
	
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
	node = ASTNode(type_="Block")
	ST.new_scope()
	
	if token != "{":
		Statement(node)
		return node
	
	MatchString("{")
	while token != "}":
		Statement(node)
	MatchString("}")
	
	ST.close_scope()
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
	elif value == "do":
		node.children.append(DoWhile())
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
	elif DoesTypeFollow():
		node.children.extend(Decl())
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
	if token == ';':
		node.children.append(ASTNode(type_="Number", value="1"))
		MatchString(';')
	else:
		node.children.extend(Decl()) if DoesTypeFollow() else (node.children.append(Expression()), MatchString(';'))
	node.children.append(ASTNode(type_="Number", value="1")) if token == ';' else node.children.append(Expression())
	MatchString(';')
	node.children.append(ASTNode(type_="Number", value="0")) if token == ")" else node.children.append(Expression())
	MatchString(')')
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
		
		c = Factor()
		c = opt.FoldConstants(c)
		if not c.type == 'Number':
			Expected('constant numeric expression')
		node.children[1].append(c)
		
		MatchString(":")
		
		node.children.append(Case())
	if value == "default":
		MatchString("default")
		MatchString(":")
		
		node.children[1].append(None)
		node.children.append(Case())
	MatchString("}")
	
	return node

def DoWhile():
	node = ASTNode(type_="ControlStructure",value="DOWHILE",children=[])
	MatchString("do")
	node.children.append(Block())
	MatchString("while")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
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

def Decl():
	node_array = []
	
	c23_attributes, gcc_attributes = [], []
	while token == '[' or value == '__attribute__':
		if token == '[':		c23_attributes += ParseC23Attributes()
		if value == '__attribute__':	gcc_attributes += ParseGccAttributes()
	
	if not DoesTypeFollow():
		Expected('type')
	
	is_typedef = False
	if value == 'typedef':
		Next()
		is_typedef = True
	
	base_type = ParseBaseType()
	
	if isinstance(base_type, ctypes.StructType) and token == '{':
		node_array.append(StructDecl(base_type))
		if token == ';':
			MatchString(';')
			return node_array
	
	d = DeclPart(base_type)
	
	d['attributes'] += c23_attributes + gcc_attributes
	if Attribute(vendor='roverc', name='stdcall') in d['attributes'] and Attribute(vendor='roverc', name='varargs') in d['attributes']:
		abort('A function with undefined argument count cannot use a callee stack cleaning calling convention')
	
	node = ASTNode(type_='Decl',value=d,children=[])
	
	if is_typedef:
		ST.add_symbol(d['name'], d['type'])
		MatchString(';')
	
	elif isinstance(d['type'], ctypes.FunctionType):
		if isinstance(d['type'].ret, ctypes.ArrayType):
			abort('A function can\'t return an array')
		if isinstance(d['type'].ret, ctypes.StructType):
			abort('A function can\'t return a struct')
		if token == '{':
			node.children.append(Block())
		else:
			MatchString(';')
		
		node_array.append(node)
		
	else:
		
		if token == '=':
			Next()
			node.children = [Expression()]
		node_array.append(node)
		
		while token == ',':
			Next()
			name = value
			node = ASTNode(type_='Decl', value=DeclPart(base_type), children=[])
			if token == '=':
				Next()
				node.children = [Expression()]
			node_array.append(node)
		
		MatchString(';')
	
	return node_array

def DoesTypeFollow():
	return value in base_types + type_modifiers or value == 'struct' or value == 'typedef' or ST.symbol_exists(value)

def ParseModifiers():
	modifiers = []
	while value in type_modifiers:
		if value in modifiers:
			abort(f'duplicate type modifier ({value})')
		modifiers.append(value)
		Next()
	
	if 'signed' in modifiers and 'unsigned' in modifiers:
		abort('conflicting modifiers: signed and unsigned')
	
	const = 'const' in modifiers
	signed = 'unsigned' not in modifiers # signed is the default
	
	return signed, const

def ParseBaseType():
	if value == 'struct':
		Next()
		name = value
		Next()
		return ctypes.StructType(name=name)
	elif ST.symbol_exists(value):
		name = value
		Next()
		return ST.get_symbol_value(name)
	
	signed, const = ParseModifiers()
	
	if not value in base_types:
		Expected('base type')
	
	base_type = value
	Next()
	
	if base_type == 'void':
		t = ctypes.VoidType()
	
	else:
		size = {'char': 1, 'short': 2, 'int': 4}[base_type]
		t = ctypes.NumberType(size=size, signed=signed, const=const)
	
	return t

def StructDecl(base_type):
	MatchString('{')
	members = []
	while token != '}':
		members += Decl()
	MatchString('}')
	return ASTNode(type_='StructDecl', value=base_type.name, children=members)

def DeclPart(t, abstract=False):
	parentheses = False
	
	if token == 'x':
		name = value
		Next()
		d = {'name': name, 'type': t, 'attributes': []}
	
	elif token == '*':
		t = ctypes.PointerType(arg=t)
		Next()
		d = DeclPart(t, abstract)
	
	elif token == '(':
		parentheses = True
		MatchString('(')
		empty = ctypes.EmptyType()
		d = DeclPart(empty, abstract)
		MatchString(')')
	
	else:
		if abstract:
			d = {'name': None, 'type': t}
		else:
			Expected('name')
	
	if token == '(':
		MatchString('(')
		
		args = []
		
		if token != ')':
			
			while True:
				
				if token == '.':
					MatchString('.')
					MatchString('.')
					MatchString('.')
					d['attributes'].append(Attribute(vendor='roverc', name='varargs'))
					
					break
				
				base_type = ParseBaseType()
				arg = DeclPart(base_type, abstract=True)
				
				if isinstance(arg['type'], ctypes.VoidType):
					if len(args) > 0:
						abort('Function with \'void\' parameter must not take other parameters')
					break
				
				if isinstance(arg['type'], ctypes.StructType):
					abort('A function can\'t have an argument with type struct')
				if isinstance(arg['type'], ctypes.ArrayType):
					abort('A function can\'t have an argument with type array')
				args.append(arg)
				
				if token == ')':
					break
				
				MatchString(',')
		
		MatchString(')')
		
		if parentheses:
			empty.make_function(args=args, ret=t)
		else:
			d['type'] = ctypes.FunctionType(args=args, ret=d['type'])
	
	elif token == '[':
		MatchString('[')
		
		index = Expression()
		index = opt.FoldConstants(index)
		if not index.type == 'Number':
			Expected('constant numeric expression')
		l = int(index.value)
		
		MatchString(']')
		
		if parentheses:
			empty.make_array(arg=t, len=l)
		else:
			d['type'] = ctypes.ArrayType(arg=d['type'], len=l)
	
	return d

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
		return token != '=' and token != '|'
	return ExpressionLevel(BitwiseXor, token_set={'|'},next_token_predicate=next_token_predicate)

def BitwiseXor():
	return ExpressionLevel(BitwiseAnd, token_set={'^'})

def BitwiseAnd():
	def next_token_predicate(op,token):
		return token != '=' and token != '&'
	return ExpressionLevel(Relation, token_set={'&'},next_token_predicate=next_token_predicate)

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
		node = ASTNode(type_="PrefixUnaryOp",value=inc_sequence,children=[ArrayFactor()])
	else:
		node = ArrayFactor()
	
	inc_sequence = IncSequence()
	if inc_sequence != "":
		return ASTNode(type_="PostfixUnaryOp",value=inc_sequence,children=[node])
	return node

def ArrayFactor():
	node = FuncFactor()
	
	if token == '[':
		Next()
		node = ASTNode(type_='ArrayAccess', value=None, children=[node, Expression()])
		MatchString(']')
	
	return node

def FuncFactor():
	node = StructFactor()
	
	if token == '(':
		node = ASTNode(type_='FunctionCall', value=None, children=[node, ArgumentListCall()])
		MatchString(')')
	
	return node

def StructFactor():
	node = Factor()
	
	while token in ['.', '-']:
		if token == '.':
			Next()
			node = ASTNode(type_='StructMemberAccess', value=None, children=[node, Factor()])
		elif token == '-':
			Next()
			if token != '>':
				Previous()
				return node
			Next()
			node = ASTNode(type_='StructPointerMemberAccess', value=None, children=[node, Factor()])
	
	return node

def ArgumentListCall():
	node = ASTNode(type_="ArgumentListCall", value=None, children=[])
	MatchString('(')
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
		if token == '-':
			Next()
			value = '-' + value
		else:
			Next() # The token is '+'
	
	if token == '0':
		node = ASTNode(type_='Number', value=int(value))
		Next()
	elif token == '!':
		MatchString('!')
		return ASTNode(type_='PrefixUnaryOp', value='!', children=[Expression()])
	elif token == '~':
		MatchString('~')
		return ASTNode(type_='PrefixUnaryOp', value='~', children=[Expression()])
	elif token == 'x':
		name = value
		Next()
		if name == 'sizeof':
			MatchString('(')
			base_t = ParseBaseType()
			new_t = DeclPart(base_t, abstract=True)['type']
			MatchString(')')
			node = ASTNode(type_='SizeOf', value=new_t)
		else:
			node = ASTNode(type_='Variable', value=name)
	elif token == '*':
		Next()
		node = ASTNode(type_='Dereference', children=[Factor()])
	elif token == '&':
		Next()
		node = ASTNode(type_='Addr', children=[Factor()])
	elif token == 's':
		node = ASTNode(type_='String', value=value)
		Next()
	elif token == '(':
		Next()
		if DoesTypeFollow():
			base_t = ParseBaseType()
			new_t = DeclPart(base_t, abstract=True)['type']
			MatchString(')')
			node = ASTNode(type_='TypeCast', value=new_t, children=[Factor()])
		else:
			node = Expression()
			MatchString(')')
	else:
		Expected('factor')
	
	return node
