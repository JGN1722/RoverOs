"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The second stage of the compiler, that takes a stream of tokens and expands the preprocessor directives. The only directives supported right now are INCLUDE and a limited DEFINE
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

# Error functions
def abort(s):
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit()

def Expected(s):
	abort("Expected " + s)

# Parsing unit
def Next():
	global token_stream, streampos, token, value, file_name, line_number, character_number
	
	streampos += 1
	
	new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def Previous():
	global token_stream, streampos, token, value, file_name, file_number, character_number
	
	streampos -= 1
	
	new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def MatchString(t):
	if value == t:
		Next()
	else:
		Expected(t)

def GetMacroValue():
	# It's gonna remain kinda shit until I decide to refactor it
	token_array = []
	
	# Basically, an expression can be one of two things
	# Either it's a name or a string or idk what, and it's an immediate token
	# Or it's a number, and in that case I have some parsing to do (but not too much,
	# I'm just sticking to shitcode for now. I pinky promise I'll refactor it)
	if token == "0":
		token_array.append(token_stream[streampos])
		Next()
		while token in ["+","-","*","/"]:
			token_array.append(token_stream[streampos])
			Next()
			if not token == "0":
				Expected("Numeric expression")
			token_array.append(token_stream[streampos])
			Next()
	
	else:
		token_array.append(token_stream[streampos])
		Next()
	
	return token_array

def DefineDirective():
	global token_stream
	
	MatchString("#")
	MatchString("DEFINE")
	macro_name = value
	Next()
	
	macro_value = GetMacroValue()
	
	# Replace all macro_name occurences by macro_value
	i = streampos
	while i < len(token_stream):
		if token_stream[i][0] == "x" and token_stream[i][1] == macro_name:
			v1, v2, v3 = token_stream[i][2], token_stream[i][3], token_stream[i][4]
			del token_stream[i]
			for j in range(len(macro_value)):
				token_stream.insert(i + j, (macro_value[j][0], macro_value[j][1], v1, v2, v3))
			i += len(macro_value)
			continue
		i += 1
	
	# Go back and erase the directive from the token stream
	Previous() # Point back to the macro value end
	for i in range(len(macro_value)): # Point back to the macro name
		Previous()
	Previous() # Point back to 'DEFINE'
	Previous() # Point back to '#'
	
	for i in range(len(macro_value) + 3): # 3 is the number of tokens in: #DEFINE MACRO_NAME
		del token_stream[streampos]
	
	Previous() # So if another directive directly follows, the main loop can find it

def IncludeFile(new_source_file_token, new_source_file_name):
	global lookahead, file_name, line_number, character_number, token, value
	
	if not new_source_file_token == "s":
		Expected("name of file to include (not" + new_source_file_name + ")")
	if new_source_file_name == "":
		abort("source file not specified")
	
	new_source_file = get_abs_path(new_source_file_name, os.path.dirname(file_name))
	
	if not os.path.isfile(new_source_file):
		abort("source file not found (" + new_source_file + ")")
	
	tokenizer.file_name = get_abs_path(new_source_file, script_directory)
	tokenizer.source_text = open(new_source_file).read()
	return tokenizer.Tokenize()

def IncludeDirective():
	MatchString("#")
	MatchString("INCLUDE")
	file = value
	file_token = token
	
	Previous()
	Previous()
	
	for i in range(3):
		del token_stream[streampos]
	
	new_stream = IncludeFile(file_token, file)
	
	for i in range(len(new_stream)):
		token_stream.insert(streampos + i, new_stream[i])
	
	Previous()

def PreprocessorDirective():
	MatchString("#")
	if not token == "x":
		Expected("Preprocessor directive (instead of " + value + ")")
	directive = value
	Previous()
	
	if directive == "DEFINE":
		DefineDirective()
	else:
		abort("Unrecognized preprocessor directive (" + directive + ")")

def CheckIncludeDirective():
	MatchString("#")
	if not token == "x":
		Expected("Preprocessor directive (instead of " + value + ")")
	directive = value
	Previous()
	
	if directive == "INCLUDE":
		IncludeDirective()
	else:
		pass # We only treat include directives here

# In order to run this routine, this module must have received a token_stream
def Preprocess():
	global streampos, token, value
	
	streampos = -1
	token = ""
	value = ""
	
	# Only process includes right now
	while streampos < len(token_stream) - 1:
		Next()
		if token == "#":
			CheckIncludeDirective()
	
	# Iterate once more now that all the code has been read
	streampos = -1
	token = ""
	value = ""
	
	while streampos < len(token_stream) - 1:
		Next()
		if token == "#":
			PreprocessorDirective()
	
	return token_stream