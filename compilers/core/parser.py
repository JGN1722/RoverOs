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
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit()

def Expected(s):
	abort("Expected " + s)



class ASTNode:
	def __init__(self, type_, children=None, value=None):
		self.type = type_
		self.children = children or []
		self.value = value

	def __repr__(self):
		return f"ASTNode(type={self.type}, value={self.value}, children={self.children})"


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
	# Generate the AST for an expression
	global AST
	Next()
	AST = ASTNode(type_="Program",children=[])
	
	while token != "\0":
		if value == "STRUCT":
			AST.children.append(StructDecl())
		else:
			AST.children.append(GlobalIdentifier())

	# Return the AST
	return AST

def StructDecl():
	MatchString("STRUCT")
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
	ParseType()
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
	function_type = ParseType()
	function_name = value
	Next()
	node = ASTNode(type_="Function",value={"name":function_name,"type":function_type},children=[ArgumentList(),Block()])
	
	return node

def ArgumentList():
	MatchString("(")
	node = ASTNode(type_="ArgumentList",children=[])
	
	if token != ")":
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
	
	if value == "STRUCT":
		Next()
	t = value
	Next()
	
	while token == "*":
		pointer_level += 1
		Next()
	
	return Type_(t,pointer_level)

def Block():
	MatchString("{")
	node = ASTNode(type_="Block")

	while not token == "}":
		if value == "IF":
			node.children.append(If())
		elif value == "WHILE":
			node.children.append(While())
		elif token == "{":
			node.children.append(Block())
		elif value == "RETURN":
			node.children.append(Return())
			MatchString(";")
		elif value == "ASM":
			node.children.append(Asm())
			MatchString(";")
		elif value == "BREAK":
			node.children.append(Break())
			MatchString(";")
		elif value == "STRUCT" or IsBuiltInType(value):
			node.children.extend(LocDecl())
			MatchString(";")
		else:
			node.children.append(Expression())
			MatchString(";")
	
	MatchString("}")
	
	return node


def If():
	node = ASTNode(type_="ControlStructure",value="IF",children=[])
	MatchString("IF")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	node.children.append(Block())
	while value == "ELSEIF":
		Next()
		MatchString("(")
		elseif_node = ASTNode(type_="ControlStructure",value="ELSEIF",children=[Expression()])
		MatchString(")")
		elseif_node.children.append(Block())
		node.children.append(elseif_node)
	if value == "ELSE":
		Next()
		else_node = ASTNode(type_="ControlStructure",value="ELSE",children=[Block()])
		node.children.append(else_node)
	return node

def While():
	node = ASTNode(type_="ControlStructure",value="WHILE",children=[])
	MatchString("WHILE")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	node.children.append(Block())
	return node

def Return():
	node = ASTNode(type_="ControlStructure",value="RETURN",children=[])
	MatchString("RETURN")
	node.children.append(Expression())
	return node

def Asm():
	node = ASTNode(type_="ControlStructure",value="ASM",children=[])
	MatchString("ASM")
	MatchString("(")
	node.children.append(Expression())
	MatchString(")")
	return node

def Break():
	MatchString("BREAK")
	return ASTNode(type_="ControlStructure",value="BREAK")


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
	node = AndTerm()
	
	while IsOrop(value):
		op = value
		Next()
		
		if token == "=": # That's actually a compound assignement, backtrack then
			Previous()
			break
		
		if op == "|":
			MatchString("|") # Ask for || instead of |
			op = "||"
		
		right = AndTerm()
		node = ASTNode(type_="BinaryOp", children=[node, right], value=op)
	
	return node

def AndTerm():
	node = NotTerm()
	
	while IsAndop(value):
		op = value
		Next()
		
		if token == "=": # That's actually a compound assignement, backtrack then
			Previous()
			break
		
		if op == "&":
			MatchString("&") # Ask for && instead of &
			op = "&&"
		
		right = NotTerm()
		node = ASTNode(type_="BinaryOp", children=[node, right], value=op)
	
	return node

def NotTerm():
	if token == "!":
		Next()
		return ASTNode(type_="UnaryOp", value="!", children=[Relation()])
	return Relation()

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
	node = AssignExpression()
	
	relation_operator = RelationSequence()
	while relation_operator != "":
		right = AssignExpression()
		node = ASTNode(type_="Relation", children=[node, right], value=relation_operator)
		
		relation_operator = RelationSequence()
	
	return node

def AssignementSequence():
	if token == "=":
		Next()
		if token == "=": # Backtrack, we're in a relation
			Previous()
			return ""
		return "="
	elif token in ["-","+","/","%","*","|","~","&"]:
		first_token = token
		Next()
		if token != "=":
			Previous()
			return ""
		Next()
		print(first_token + "=")
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
		print(first_token + "=")
		return first_token + "="
	return ""

def AssignExpression():
	node = NumericExpression()
	
	assign_operator = AssignementSequence()
	while assign_operator != "":
		right = NumericExpression()
		node = ASTNode(type_="Assignement", children=[node, right], value=assign_operator)
		
		assign_operator = AssignementSequence()
	
	return node

def NumericExpression():
	# Parse a term and look for "+" or "-" operators
	node = Term()
	while IsAddop(token):
		op = token
		Next()
		if token == "=" or token == op: # That's actually a compound assignement, backtrack then
			Previous()
			break
		right = Term()
		node = ASTNode(type_="BinaryOp", children=[node, right], value=op)
	
	return node


def Term():
	# Parse a bitwise factor and look for "*", "/", or "%" operators
	node = BitwiseFactor()
	while IsMulop(token):
		op = token
		Next()
		if token == "=": # That's actually a compound assignement, backtrack then
			Previous()
			break
		right = BitwiseFactor()
		node = ASTNode(type_="BinaryOp", children=[node, right], value=op)
	return node


def BitwiseFactor():
	# Parse a factor and look for "<<" or ">>" operators
	node = UnaryFactor()
	Next()
	next_token = token
	Previous()
	while (token == ">" and next_token == ">") or (token == "<" and next_token == "<"):
		op = token + next_token
		Next()
		Next()
		if token == "=": # That's actually a compound assignement, backtrack then
			Previous()
			Previous()
			break
		right = UnaryFactor()
		node = ASTNode(type_="BinaryOp", children=[node, right], value=op)
	return node

def UnaryFactor():
	node = Factor()
	
	if IsAddop(token):
		op = token
		Next()
		if token != op:
			Previous()
			return node
		op += op
		Next()
		return ASTNode(type_="UnaryOp", value=op, children=[node])
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

