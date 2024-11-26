import sys

from helpers import *

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
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit()

def Warning(s):
	print("Warning: " + s, "(file", file_name, "line", line_number, "character", character_number, ")")

def Expected(s):
	abort("Expected " + s)

def GetChar():
	global streampos, lookahead, character_number, line_number
	
	if streampos >= len(source_text):
		lookahead = "\0"
	else:
		lookahead = source_text[streampos]
		streampos += 1
		
		# Update the line and character values, used for error reporting
		character_number += 1
		if lookahead == chr(10):
			line_number += 1
			character_number = 1

def SkipWhite():
	global lookahead, last_whitespace_call_got_newline
	
	last_whitespace_call_got_newline = False
	while lookahead in [" ", "	", chr(10), chr(13)]:
		GetChar()

def GetName():
	global lookahead, token, value
	
	SkipWhite()
	if not IsAlpha(lookahead.upper()):
		Expected("Name")
	token = "x"
	value = ""
	while IsAlnum(lookahead):
		value += lookahead.upper()
		GetChar()

def GetNum():
	global lookahead, token, value
	
	SkipWhite()
	if not IsDigit(lookahead):
		Expected("Number")
	token = "0"
	value = lookahead
	GetChar()
	
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
		value += "h"
	elif base == 2:
		value += "b"

def GetOp():
	global lookahead, token, value
	
	token = lookahead
	value = lookahead
	GetChar()

def GetString():
	global lookahead, token, value
	
	if not lookahead == chr(34):
		Expected("String")
	GetChar()
	token = "s"
	value = ""
	while not lookahead == chr(34):
		if lookahead == "\0":
			abort("unfinished string literal")
		value += lookahead
		GetChar()
	GetChar()

def GetAsciiCode():
	global lookahead, token, value
	
	if not lookahead == "'":
		Expected("Ascii literal")
	token = "0"
	GetChar()
	value = str(ord(lookahead))
	GetChar()
	if not lookahead == "'":
		abort("more than one character in ascii literal")
	GetChar()

def next_token_comment():
	global lookahead
	
	if IsDigit(lookahead):
		GetNum()
	elif IsAlpha(lookahead):
		GetName()
	else:
		GetOp()

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

def next_token():
	global lookahead, token_stream
	
	SkipWhite()
	if IsDigit(lookahead):
		GetNum()
	elif IsAlpha(lookahead):
		GetName()
	elif lookahead == chr(34):
		GetString()
	elif lookahead == "'":
		GetAsciiCode()
	else:
		GetOp()
		if token == "/":
			if lookahead == "*":
				SkipPrologueComment()
			elif lookahead == "/":
				SkipInlineComment()

def Tokenize(is_main_file=False):
	global token_stream, streampos, token_stream, lookahead, source_text, line_number, character_number, file_name
	
	streampos = 0
	current_file_name = file_name
	line_number, character_number = 1, 1
	old_line_number, old_character_number = 1, 1
	
	GetChar()
	next_token()
	while token != "\0":
		if token == "x" and value == "INCLUDE":
			next_token()
			IncludeFile(token, value)
			next_token()
		else:
			token_stream.append((token,value, file_name, old_line_number, old_character_number))
			old_line_number, old_character_number = line_number, character_number
			
			next_token()
	
	if is_main_file:
		token_stream.append(("\0", "\0", current_file_name, line_number, character_number))
		
		# Clean the namespace a bit
		del lookahead
		del source_text
		
		return token_stream

def IncludeFile(new_source_file_token, new_source_file_name):
	global source_text, streampos, lookahead, file_name, line_number, character_number, token, value
	
	if not new_source_file_token == "s":
		Expected("name of file to include (not" + new_source_file_name + ")")
	if new_source_file_name == "":
		abort("source file not specified")
	
	new_source_file = get_abs_path(new_source_file_name, os.path.dirname(file_name))
	
	if not os.path.isfile(new_source_file):
		abort("source file not found (" + new_source_file + ")")
	
	(tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8) = source_text, streampos, lookahead, file_name, line_number, character_number, token, value
	file_name = get_abs_path(new_source_file, script_directory)
	source_text = open(new_source_file).read()
	Tokenize()
	source_text, streampos, lookahead, file_name, line_number, character_number, token, value = (tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8)
