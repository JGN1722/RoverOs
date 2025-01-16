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

defined_macros = {}

# Error functions
def abort(s):
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit(-1)

def Expected(s):
	abort("Expected " + s)

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

def RemoveToken():
	global token_stream, streampos, token, value, file_name, line_number, character_number
	
	if streampos >= len(token_stream) - 1:
		new_token = token_stream[-1]
	else:
		del token_stream[streampos]
		new_token = token_stream[streampos]
	token, value, file_name, line_number, character_number = new_token

def MatchString(t):
	if value == t:
		Next()
	else:
		Expected(t)

def GetMacroValue():
	token_array = []
	
	# I'll get every token until I encounter a newline
	while not token in [chr(10), chr(13), '\0']:
		token_array.append(token_stream[streampos])
		Next()
	
	return token_array

def DefineDirective():
	global token_stream
	
	MatchString("#")
	MatchString("define")
	macro_name = value
	Next()
	
	macro_value = GetMacroValue()
	
	# Store the macro in a table
	defined_macros[macro_name] = macro_value
	
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
	MatchString("include")
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

def Preprocess():
	global streampos, token, value
	
	streampos = -1
	token = ""
	value = ""
	
	directive = ""
	
	Next()
	
	while not token == "\0":
		
		# Loop until we encounter a directive or a null token
		while token != "#":
			
			if token == "\0":
				break
			
			# We need to operate a bit on the token before going to the next:
			# There can be macros to expand, and newlines to remove
			if token == "\n":
				RemoveToken()
			elif value in defined_macros.keys():
				# Replace all macro_name occurences by macro_value
				macro_value = defined_macros[value]
				
				for j in range(len(macro_value)):
					token_stream.insert(streampos + j + 1, (macro_value[j][0], macro_value[j][1], file_name, line_number, character_number))
				RemoveToken()
			else:
				Next()
		
		Next()
		directive = value
		Previous()
		
		if not token == "\0":
			if directive == "include":
				IncludeDirective()
			elif directive == "define":
				DefineDirective()
			
			Next()
	
	return token_stream
