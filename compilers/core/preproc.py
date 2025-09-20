"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The second stage of the compiler, that takes a stream of tokens and expands the preprocessor directives
It implements a limited yet working preprocessor, with #include, #define, #undef, #ifdef, #ifndef, #error and #warning
"""

import sys

from core.helpers import *
import core.tokenizer as tokenizer
import core.error as err

script_directory = ''
include_directory = ''
fmt = ''

token_stream = []
streampos = -1
token = ''
value = ''
file_name = ''
line_number = 0
character_number = 0

defined_macros = {
	'_ROVERC':[[],[]],
	'_WIN32':[[],[]],
	'VA_ARG': [[
			(' ', ' '), ('(', '('), ('(', '('),
			('x', 'T'), (')', ')'), ('(', '('),
			('*', '*'), ('(', '('), ('(', '('),
			('x', 'T'), (' ', ' '), ('*', '*'),
			(')', ')'), ('(', '('), ('(', '('),
			('&', '&'), ('x', 'REF_ARG'), (')', ')'),
			(' ', ' '), ('+', '+'), (' ', ' '),
			('x', 'I'), (' ', ' '), ('*', '*'),
			(' ', ' '), ('0', '4'), (')', ')'),
			(')', ')'), (')', ')'), (')', ')')
		], ['REF_ARG', 'I', 'T']]
}

# Error functions
def abort(s):
	err.abort(s + ' (file ' + file_name + ' line ' + str(line_number) + ' character ' + str(character_number) + ')')

def Expected(s):
	abort('Expected ' + s)


# Parsing unit
def Next():
	global token_stream, streampos, token, value, file_name, line_number, character_number

	streampos += 1
	
	if streampos >= len(token_stream):
		new_token = token_stream[-1]
	else:
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def Previous():
	global token_stream, streampos, token, value, file_name, file_number, character_number
	
	streampos -= 1
	
	new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def Reload():
	global token_stream, token, value, file_name, line_number, character_number

	if streampos >= len(token_stream):
		new_token = token_stream[-1]
	else:
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def RemoveToken():
	global token_stream, streampos, token, value, file_name, line_number, character_number
	
	if streampos >= len(token_stream) - 1:
		new_token = token_stream[-1]
	else:
		del token_stream[streampos]
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def MatchRemoveToken(s):
	if value != s:
		Expected(s)
	RemoveToken()

def MatchString(t):
	if value == t:
		Next()
	else:
		Expected(t)

def GetAndRemoveMacroValue():
	macro_value = []
	
	# I'll get every token until I encounter a newline
	while not token in ["\n","\0"]:
		macro_value.append((token,value))
		RemoveToken()
	
	if token == "\n":
		RemoveToken()
	
	return macro_value

def DefineDirective():
	MatchRemoveToken("#")
	MatchRemoveToken("define")
	if not IsBlankNotNewline(value):
		Expected("Space")
	RemoveToken()
	if not token == "x":
		Expected("Name")
	macro_name = value
	RemoveToken()
	
	if macro_name in defined_macros:
		abort('Macro redefinition: ' + macro_name)
	
	macro_params = []
	
	# Maybe the macro has parameters
	if token == "(":
		MatchRemoveToken("(")
		while IsBlankNotNewline(token):
			RemoveToken()
		if not token == "x":
			Expected("Name")
		macro_params.append(value)
		RemoveToken()
		while IsBlankNotNewline(token):
			RemoveToken()
		
		while token == ",":
			MatchRemoveToken(",")
			while IsBlankNotNewline(token):
				RemoveToken()
			if not token == "x":
				Expected("Name")
			macro_params.append(value)
			RemoveToken()
			while IsBlankNotNewline(token):
				RemoveToken()
		
		MatchRemoveToken(")")
	
	macro_value = GetAndRemoveMacroValue()
	
	# Store the macro in a table
	defined_macros[macro_name] = [macro_value,macro_params]

def IncludeFile(new_source_file_name):
	if new_source_file_name == "":
		abort("source file not specified")
	
	new_source_file = get_abs_path(new_source_file_name, os.path.dirname(file_name))
	
	if not os.path.isfile(new_source_file):
		abort("source file not found (" + new_source_file + ")")
	
	tokenizer.file_name = get_abs_path(new_source_file, script_directory)
	tokenizer.source_text = open(new_source_file).read()
	return tokenizer.Tokenize()

def IncludeDirective():
	MatchRemoveToken("#")
	MatchRemoveToken("include")
	if not IsBlankNotNewline(value):
		Expected("Space")
	RemoveToken()
	
	if not token in ['"', '<']:
		Expected('Quoted string or include path')
	
	is_std_file = token != '"'
	BuildString() if token == '"' else BuildIncludeString()
	
	if token != "s":
		Expected("name of file to include (not " + value + ")")
	
	file = value
	
	new_stream = IncludeFile(include_directory + file if is_std_file else file)
	RemoveToken()
	
	for i in range(len(new_stream)):
		token_stream.insert(streampos + i, new_stream[i])
	
	Reload()

def UndefDirective():
	MatchRemoveToken("#")
	MatchRemoveToken("undef")
	if not IsBlankNotNewline(value):
		Expected("Space")
	RemoveToken()
	if not token == "x":
		Expected("Name")
	macro_to_remove = value
	RemoveToken()
	
	if macro_to_remove in defined_macros.keys():
		del defined_macros[macro_to_remove]

def SkipToNextEndif():
	while token != "\0":
		if token == "#":
			Next()
			directive = value
			Previous()
			if directive == "endif":
				return
		RemoveToken()
	
	Expected("#endif directive")

def IfdefDirective():
	MatchRemoveToken("#")
	MatchRemoveToken("ifdef")
	if not IsBlankNotNewline(value):
		Expected("Space")
	RemoveToken()
	if not token == "x":
		Expected("Name")
	macro_to_check = value
	RemoveToken()
	
	if macro_to_check in defined_macros.keys():
		PreprocessTokenBlock(root_level=False)
	else:
		SkipToNextEndif()
	
	# Now, we made sure we have a #endif directive
	MatchRemoveToken("#")
	MatchRemoveToken("endif")

def IfndefDirective():
	MatchRemoveToken("#")
	MatchRemoveToken("ifndef")
	if not IsBlankNotNewline(value):
		Expected("Space")
	RemoveToken()
	if not token == "x":
		Expected("Name")
	macro_to_check = value
	RemoveToken()
	
	if not macro_to_check in defined_macros.keys():
		PreprocessTokenBlock(root_level=False)
	else:
		SkipToNextEndif()
	
	# Now, we made sure we have a #endif directive
	MatchRemoveToken("#")
	MatchRemoveToken("endif")

def ErrorDirective():
	error_string = ""
	MatchRemoveToken("#")
	MatchRemoveToken("error")
	
	while token != "\n" and token != "\0":
		error_string += value
		RemoveToken()
	
	abort(error_string.lstrip())

def WarningDirective():
	warning_string = ""
	MatchRemoveToken("#")
	MatchRemoveToken("warning")
	
	while token != "\n" and token != "\0":
		warning_string += value
		RemoveToken()
	
	err.warning(warning_string.lstrip())

def BuildString():
	l,c,f = line_number, character_number, file_name
	MatchRemoveToken(chr(34))
	string_value = ""
	while token != chr(34):
		if token == "\0":
			abort("Unterminated string literal at line " + str(l) + ", character " + str(c))
		string_value += value
		RemoveToken()
	MatchRemoveToken(chr(34))
	token_stream.insert(streampos, ("s", string_value, f, l, c))
	
	Reload()

def BuildIncludeString():
	l,c,f = line_number, character_number, file_name
	MatchRemoveToken('<')
	string_value = ''
	while token != '>':
		if token == '\0':
			abort("Unterminated string literal at line " + str(l) + ", character " + str(c))
		string_value += value
		RemoveToken()
	MatchRemoveToken('>')
	token_stream.insert(streampos, ('s', string_value, f, l, c))
	
	Reload()

def BuildChar():
	l, c = line_number, character_number
	MatchRemoveToken("'")
	if token == '\\':
		RemoveToken()
		if len(value) != 1:
			Expected('single character')
		if value == 'n':
			char_value = '13'
		elif value == 't':
			char_value = '9'
		elif value == '\\':
			char_value = str(ord('\\'))
		elif value == "'":
			char_value = str(ord("'"))
		elif value == 'r':
			char_value = '10'
		elif value == '0':
			char_value = '0'
		else:
			Expected('valid escape sequence')
	else:
		if len(value) != 1:
			Expected('single character')
		char_value = str(ord(value))
	RemoveToken()
	MatchRemoveToken("'")
	token_stream.insert(streampos, ('0', char_value, file_name, l, c))
	
	Reload()

def ExtendMacro(macro_name):
	macro_value = defined_macros[macro_name][0]
	macro_params = defined_macros[macro_name][1]
	macro_args = []
	
	if macro_params != []:
		Next()
		MatchRemoveToken("(")
		
		current_arg = []
		while not token in [")",","]:
			if token == "\0":
				abort("Unfinished macro parameter list")
			current_arg.append((token,value))
			RemoveToken()
		macro_args.append(current_arg)
		while token == ",":
			current_arg = []
			MatchRemoveToken(",")
			while not token in [")",","]:
				if token == "\0":
					abort("Unfinished macro parameter list")
				current_arg.append((token,value))
				RemoveToken()
			macro_args.append(current_arg)
		
		MatchRemoveToken(")")
		Previous()
		
		if len(macro_args) != len(macro_params):
			abort("Wrong number of arguments when calling macro " + macro_name + ": " + str(len(macro_args)) + " instead of " + str(len(macro_params)))
	
	k = 0 # k is the number of tokens of arguments that have been expanded
	
	for j in range(len(macro_value)):
		index = -1
		for i in range(len(macro_params)):
			if macro_value[j][1] == macro_params[i]:
				index = i
		
		if index == -1:
			token_stream.insert(streampos + j + k + 1, (macro_value[j][0], macro_value[j][1], file_name, line_number, character_number))
		else:
			for l in range(len(macro_args[index])):
				token_stream.insert(streampos + j + k + l + 1, (macro_args[index][l][0], macro_args[index][l][1], file_name, line_number, character_number))
			k += len(macro_args[index]) - 1
	
	RemoveToken()

def BuildNumber():
	l, c = line_number, character_number
	if value != '0':
		return;
	
	Next()
	v = value.lower()
	
	if v[0] != 'x' and v[0] != 'b':
		return
	
	# We now established that we're parsing a number with
	# a specified base (0x... or 0b...)
	Previous()
	MatchRemoveToken('0')
	
	base = 2 if v[0] == 'b' else 16
	
	if v[1:] == '':
		Expected('Valid numeric value')
	
	v = v[1:]
	
	n = 0
	if base == 2:
		# We're expecting a single number, with only 0 and 1
		k = 2 ** (len(v) - 1)
		for c in v:
			if c != '0' and c != '1':
				abort(f'Unexpected base 2 digit ({c})')
			n += k * int(c)
			k //= 2
	
	if base == 16:
		# Now, it can be an arbitrarily long sequence of
		# identifiers and numbers, with only hex letters
		# in the identifiers
		k = 16 ** (len(v) - 1)
		for c in v:
			if IsDigit(c):
				n += k * int(c)
				k //= 16
			elif IsHexDigit(c):
				o = ord(c)
				n += k * (o - ord('a') + 10)
				k //= 16
			else:
				abort(f'Unexpected base 16 digit ({c})')
	
	RemoveToken()
	token_stream.insert(streampos, ('0', str(n), file_name, l, c))
	Reload()

def PreprocessTokenBlock(root_level=True):
	
	while not token == "\0":
		
		# Loop until we encounter a directive or a null token
		while token != "#":
			if token == "\0":
				if not root_level:
					Expected("#endif directive")
				break
			
			# We need to operate a bit on the token before going to the next:
			# There can be macros to expand, and newlines to remove
			if value in defined_macros:
				ExtendMacro(value)
			elif token == '"':
				BuildString()
			elif token == "'":
				BuildChar()
			elif value == "0":
				BuildNumber()
			elif IsBlank(token):
				RemoveToken()
			else:
				Next()
		
		Next()
		directive = value
		Previous()
		
		if not root_level and (directive == "endif" or directive == "else"):
			return
		
		if not token == "\0":
			if directive == "include": # TODO: add embed, if, elif, else, elifdef, elifndef
				IncludeDirective() # Also, conditional compilation directives do not nest well
			elif directive == "define":
				DefineDirective()
			elif directive == "undef":
				UndefDirective()
			elif directive == "error":
				ErrorDirective()
			elif directive == "warning":
				WarningDirective()
			elif directive == "ifdef":
				IfdefDirective()
			elif directive == "ifndef":
				IfndefDirective()
			else:
				abort('Unknown directive: ' + directive)

def Preprocess():
	global streampos, token, value
	
	if fmt == 'f':
		del defined_macros['_WIN32']
	
	streampos = -1
	token = ''
	value = ''
	
	directive = ''
	
	Next()
	
	PreprocessTokenBlock()
	
	return token_stream
