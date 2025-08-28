"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The first stage of the compiler, that breaks up the source into an array of tokens
"""

TEST_MODE = False
last_err = ''

import sys

from core.helpers import *

"""
The approach I took there is taken from the book I first used to start writing compilers:
Jack Crenshaw's How To Build A Compiler

token is the symbol of the token currently being examined: 0 for a number, x for an identifier, and the value in any other case
value is the actual value of the token, so it's only different if the token is a number or an identifier

streampos is the index in the text
lookahead is the next character to be considered

this approach with global variables feels simpler and cleaner to me, so it's also taken in the other parts of the code
"""

source_text = ""
lookahead = ""
streampos = 0

token_stream = []
token = ""
value = ""

script_directory = ""
file_name = ""
line_number = 1
character_number = 1

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

# The backbone of the tokenizer: fetches the next character, gives null if the text is finished, and advances streampos
def GetChar():
	global streampos, lookahead, character_number, line_number
	
	# GCC-style line continuations
	if streampos <= len(source_text) - 2:
		if source_text[streampos] == '\\' and source_text[streampos + 1] == chr(10):
			streampos += 2
			line_number += 1
			character_number = 1
	
	if streampos >= len(source_text):
		lookahead = '\0'
		return
	
	lookahead = source_text[streampos]
	streampos += 1
	
	# Update the line and character values, used for error reporting
	character_number += 1
	if lookahead == chr(10):
		line_number += 1
		character_number = 1

def GetName():
	global lookahead, token, value
	
	if not IsAlpha(lookahead):
		Expected("Name")
	token = "x"
	value = ""
	while IsAlnum(lookahead):
		value += lookahead
		GetChar()

def GetNum():
	global lookahead, token, value
	
	if not IsDigit(lookahead):
		Expected("Number")
	token = "0"
	value = lookahead
	GetChar()
	
	# We handle different bases as early as we can, to avoid complexity later on
	if value == "0":
		if lookahead.upper() == "X":
			base = 16
			GetChar()
		elif lookahead.upper() == "B":
			base = 2
			GetChar()
		elif not IsDigit(lookahead) and IsAlpha(lookahead):
			abort("unexpected number base")
		else:
			base = 10
	else:
		base = 10
	
	while IsDigit(lookahead) or lookahead.upper() == "X" or IsHexDigit(lookahead):
		if (IsHexDigit(lookahead) and not IsDigit(lookahead) and base != 16) or (base == 2 and lookahead != "0" and lookahead != "1"):
			abort("unexpected character in digit ( " + lookahead + " ) in base " + str(base))
		value += lookahead
		GetChar()
	
	if base == 16:
		value = str(int(value, 16))
	elif base == 2:
		value = str(int(value, 2))
		

# What we consider to be an 'operator' is literally anything other than a number or identifier
def GetOp():
	global lookahead, token, value
	
	token = lookahead
	value = lookahead
	GetChar()

# To avoid the headache later on, we get rid of comments as soon as possible
# How it's done is if we detect a potential comment, then we switch to a different next_token
# this allows to determine if we're in a comment without the mess of global flags
def next_token_comment():
	global lookahead
	
	if IsDigit(lookahead):
		GetNum()
	elif IsAlpha(lookahead):
		GetName()
	else:
		GetOp()

# Where the comment removing magic happens
def SkipInlineComment():
	next_token_comment() # Skip the first '/' of the comment symbol
	next_token_comment() # Skip the second '/' of the comment symbol
	while not token == "\n":
		next_token_comment()
	next_token() # Prepare the terrain for the return to normal lexing

def SkipPrologueComment(main_comment=True):
	next_token_comment() # Skip the '/' of the comment symbol. The '*' will be skipped in the loop
	while True:
		next_token_comment()
		if token == "*":
			next_token_comment()
			if token == "/":
				break
		if token == "/":
			if lookahead == "*":
				SkipPrologueComment(False)
		if token == "\0":
			abort("Unfinished comment")
	if main_comment:
		next_token() # Prepare the terrain for the return to normal lexing

# The heart of the logic of this module: gets the tokens one by one, and looks for comments to skip
def next_token():
	global lookahead, token_stream
	
	if IsDigit(lookahead):
		GetNum()
	elif IsAlpha(lookahead):
		GetName()
	else:
		GetOp()
		if token == "/":
			if lookahead == "*":
				SkipPrologueComment()
			elif lookahead == "/":
				SkipInlineComment()

# In order to start this routine, the following variables must have been initialized:
# -script_directory
# -file_name
# -source_text
def Tokenize(is_main_file=False):
	global streampos, token_stream, character_number, line_number, file_name
	
	streampos = 0
	token_stream = []
	current_file_name = file_name
	line_number, character_number = 1, 1
	old_line_number, old_character_number = 1, 1
	
	GetChar()
	next_token()
	while token != "\0":
		token_stream.append((token,value, file_name, old_line_number, old_character_number - 1)) # - 1 because char number is lookahead pos + 1
		old_line_number, old_character_number = line_number, character_number
		
		next_token()
	
	if is_main_file:
		token_stream.append(("\0","\0", file_name, old_line_number, old_character_number))
	
	return token_stream
