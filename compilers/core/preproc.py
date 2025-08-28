"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The second stage of the compiler, that takes a stream of tokens and expands the preprocessor directives
It implements a limited yet working preprocessor, with #include, #define, #undef, #ifdef, #ifndef, #error and #warning
"""

TEST_MODE = False
last_err = ''

import sys

from core.helpers import *
import core.tokenizer as tokenizer

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
	global last_err
	
	if TEST_MODE:
		last_err = s
		raise TestModeError
	
	print('Error:', s, '(file', file_name, 'line', line_number, 'character', character_number, ')', file=sys.stderr)
	sys.exit(-1)

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
	global lookahead, file_name, line_number, character_number, token, value
	
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
	RemoveToken()
	
	new_stream = IncludeFile(include_directory + file if is_std_file else file)
	
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
	
	print("Warning:",warning_string)

def BuildString():
	l,c = line_number, character_number
	MatchRemoveToken(chr(34))
	string_value = ""
	while token != chr(34):
		if token == "\0":
			abort("Unterminated string literal at line " + str(l) + ", character " + str(c))
		string_value += value
		RemoveToken()
	MatchRemoveToken(chr(34))
	token_stream.insert(streampos, ("s", string_value, file_name, l, c))
	
	Reload()

def BuildIncludeString():
	l,c = line_number, character_number
	MatchRemoveToken('<')
	string_value = ''
	while token != '>':
		if token == '\0':
			abort("Unterminated string literal at line " + str(l) + ", character " + str(c))
		string_value += value
		RemoveToken()
	MatchRemoveToken('>')
	token_stream.insert(streampos, ('s', string_value, file_name, l, c))
	
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
			if IsBlank(token):
				RemoveToken()
			elif value in defined_macros:
				ExtendMacro(value)
			elif token == '"':
				BuildString()
			elif token == "'":
				BuildChar()
			else:
				Next()
		
		Next()
		directive = value
		Previous()
		
		if not root_level and (directive == "endif" or directive == "else"):
			return
		
		if not token == "\0":
			if directive == "include": # TODO: add embed, if, elif, else, elifdef, elifndef
				IncludeDirective()
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
