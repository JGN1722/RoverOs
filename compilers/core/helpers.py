"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: A set of helper functions and misc data used throughout the compiler
"""

import os
import sys

base_types = [
	'char',
	'short',
	'int',
	'void'
]

type_modifiers = [
	'signed',
	'unsigned',
	'const'
]

calling_conventions = [
	'__cdecl',
	'__stdcall'
]

keyword_list = [
	'asm',
	'if',
	'while',
	'struct',
	'for',
	'switch',
	'do',
	'return',
	'break',
	'continue',
	'typedef'
]
keyword_list += base_types
keyword_list += type_modifiers
keyword_list += calling_conventions

class ASTNode:
	def __init__(self, type_, children=None, value=None):
		self.type = type_
		self.children = children or []
		self.value = value

	def __repr__(self):
		return f"ASTNode(type='{self.type}', value='{self.value}', children={self.children})"
	
	def __eq__(self, other):
		return type(self) == type(other) and self.type == other.type and self.children == other.children and self.value == other.value

class Attribute: # TODO: better attribute handling
	def __init__(self, vendor="", name="", arguments=[]):
		self.vendor = vendor
		self.name = name
		self.arguments = arguments
	
	def __repr__(self):
		return f"Attribute(vendor='{self.vendor}', name='{self.name}', args='{self.arguments}')"
	
	def __eq__(self, other):
		return self.vendor == other.vendor and self.name == other.name and self.arguments == other.arguments

class TestModeError(Exception):
	pass

def GetSizeQualifier(s):
	return "DWORD" if s == 4 else "WORD" if s == 2 else "BYTE" if s == 1 else ""

def GetRegisterNameBySize(s):
	return "eax" if s == 4 else "ax" if s == 2 else "al" if s == 1 else ""

def GetSecondaryRegisterNameBySize(s):
	return "ebx" if s == 4 else "bx" if s == 2 else "bl" if s == 1 else ""

def IsAlpha(c):
	return ord(c.upper()) >= 65 and ord(c.upper()) <= 90 or c == "_"

def IsDigit(c):
	return ord(c) >= 48 and ord(c) <= 57

def IsHexDigit(c):
	return (ord(c) >= 48 and ord(c) <= 57) or (ord(c.upper()) >= ord("A") and ord(c.upper()) <= ord("F"))

def IsBlank(c):
	return c in [" ","	","\n"]

def IsBlankNotNewline(c):
	return c in [" ","	"]

def IsAlnum(c):
	return IsAlpha(c) or IsDigit(c)

def IsAddop(c):
	return c == "+" or c == "-"

def IsKeyword(t):
	return t in keyword_list

def FormatString(L, s): # If the list of escape sequences is changed, also change it in BuildChar(), in preproc.py
	# Define a dictionary to map C-style escape sequences to their ASCII equivalents
	escape_sequences = {
		r'\n': '\n',  # newline
		r'\t': '\t',  # tab
		r'\\': '\\',  # backslash
		r'\"': '"',   # double quote
		r'\r': '\r',  # carriage return
		r'\0': '\0',  # null character
	}
	
	# Initialize an empty result string
	r = ""

	i = 0
	while i < len(s):
		# Check if the current character is an escape sequence starter
		if s[i] == '\\' and i + 1 < len(s):
			esc_seq = s[i:i+2]  # extract the escape sequence
			if esc_seq in escape_sequences:
				# Add the ASCII value of the escaped character
				r += str(ord(escape_sequences[esc_seq])) + ", "
				i += 2  # move the index past the escape sequence
				continue
		# Add the ASCII value of the current character (non-escape)
		r += str(ord(s[i])) + ", "
		i += 1

	# Remove the trailing ", " and append the terminator
	r = r.rstrip(", ") + ", 0"
	
	return L + " db " + r

def get_abs_path(path, base_path):
	if path[:3][1:] == ":\\":
		return os.path.realpath(path)
	else:
		return os.path.realpath(base_path + "\\" + path)

def ReadSourceText(path, base_directory):
	abs_path = get_abs_path(path, base_directory)
		
	if not os.path.isfile(abs_path):
		abort("source file not found (" + abs_path + ")")
	
	file = open(abs_path)
	source_text = file.read()
	file.close()
	
	return source_text

def convert_to_ext(file_path, new_ext):
	# Split the file path into base and extension
	base, ext = os.path.splitext(file_path)
	
	# If there's no extension, just append the extension
	if ext == '':
		return file_path + '.' + new_ext
		
	# If an extension exists, replace it with the new extension
	return base + '.' + new_ext

# Error functions
def abort(s):
	print("Error: " + s, file=sys.stderr)
	sys.exit(-1)
