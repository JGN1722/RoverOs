"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The second stage of the compiler, that takes a stream of tokens and expands the preprocessor directives
"""

import sys

from core.helpers import *
import core.tokenizer as tokenizer

token_stream = []
streampos = -1
token = ""
value = ""
file_name = ""
line_number = 0
character_number = 0

defined_macros = {
	"_ROVERC":[[],[]],
	"_WIN32":[[],[]],
}

# Error functions
def abort(s):
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit(-1)

def Expected(s):
	abort("Expected " + s)

def DumpStream():
	res = ""
	for t in token_stream:
		res += t[1] + " "
	print(res)

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

def IncludeFile(new_source_file_token, new_source_file_name):
	global lookahead, file_name, line_number, character_number, token, value
	
	if not new_source_file_token == "s":
		Expected("name of file to include (not " + new_source_file_name + ")")
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
	BuildString()
	file = value
	file_token = token
	RemoveToken()
	
	new_stream = IncludeFile(file_token, file)
	
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
	
	if macro_to_check in defined_macros.keys():
		del define_macros[macro_to_check]

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
	
	abort(error_string)

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

def ExtendMacro(macro_name):
	#print("=======================================================")
	#print("the macro is at index",streampos)
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
			#print("(no arg) adding at ",streampos + j + k + 1)
			token_stream.insert(streampos + j + k + 1, (macro_value[j][0], macro_value[j][1], file_name, line_number, character_number))
		else:
			for l in range(len(macro_args[index])):
				#print("(arg   ) adding at ",streampos + j + k + l + 1)
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
			elif value in defined_macros.keys():
				ExtendMacro(value)
			elif token == chr(34):
				BuildString()
			else:
				Next()
		
		Next()
		directive = value
		Previous()
		
		if not root_level and (directive == "endif" or directive == "else"):
			return
		
		if not token == "\0":
			if directive == "include":
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

def Preprocess():
	global streampos, token, value
	
	streampos = -1
	token = ""
	value = ""
	
	directive = ""
	
	Next()
	
	PreprocessTokenBlock()
	
	return token_stream
