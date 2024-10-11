keyword_list = [
	'INT',
	'MAIN',
	'ASM',
	'WORD',
	'BYTE'
]

def IsAddop(c):
	return c == "+" or c == "-"

def IsBitWiseOp(t):
	return t == "SHL" or t == "SHR" or t == "SAR" or t == "SAL"

def IsMulop(c):
	return c == "*" or c == "/" or c == "%"

def IsRelop(c):
	return c == "<" or c == ">" or c == "=" or c == "!"

def IsOrop(c):
	return c == "|" or c == "~"

def IsType(t):
	return t == "INT"

def IsSize(t):
	return t == "DWORD" or t == "WORD" or t == "BYTE"

def IsKeyword(t):
	return t in keyword_list