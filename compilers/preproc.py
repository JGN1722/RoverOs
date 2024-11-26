import sys

from helpers import *
import tokenizer

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

def Warning(s):
	print("Warning: " + s, "(file", file_name, "line", line_number, "character", character_number, ")")

def Undefined(n):
	if IsKeyword(n):
		abort("keyword is misplaced ( " + n + " )")
	abort("undefined name ( " + n + " )")

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

def PreprocessorDirective():
	global token_stream
	
	MatchString("#")
	if not token == "x":
		Expected("Preprocessor directive")
	directive = value
	Previous()
	
	if directive == "INCLUDE":
		IncludeDirective()
	elif directive == "DEFINE":
		DefineDirective()
	else:
		abort("Unrecognized preprocessor directive (" + directive + ")")

def Preprocess():
	global streampos, token, value, token_stream
	
	streampos = -1
	token = ""
	value = ""
	
	while streampos < len(token_stream) - 1:
		Next()
		if token == "#":
			PreprocessorDirective()