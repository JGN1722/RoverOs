def GetChar():
	global streampos, lookahead
	
	if streampos >= len(source_text):
		lookahead = "\0"
	else:
		lookahead = source_text[streampos]
		streampos += 1

def Expected(s):
	abort("Expected " + s)

# I wrote MatchString in some places and Match in some others
def MatchString(t):
	Match(t)

def Match(t):
	if value == t:
		Next()
	else:
		Expected(t)

def IsAlpha(c):
	return ord(c.upper()) >= 65 and ord(c.upper()) <= 90 or c == "_"

def IsDigit(c):
	return ord(c) >= 48 and ord(c) <= 57

def IsHexDigit(c):
	return (ord(c) >= 48 and ord(c) <= 57) or (ord(c.upper()) >= ord("A") and ord(c.upper()) <= ord("F"))

def IsAlnum(c):
	return IsAlpha(c) or IsDigit(c)

def SkipWhite():
	global lookahead
	
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
	
	SkipWhite()
	token = lookahead
	value = lookahead
	GetChar()

def GetComment():
	global lookahead
	
	if not lookahead == "\\":
		Expected("Comment")
	GetChar()
	while not lookahead == "\\":
		GetChar()
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

def Next():
	global lookahead
	
	SkipWhite()
	if IsDigit(lookahead):
		GetNum()
	elif IsAlpha(lookahead):
		GetName()
	elif lookahead == chr(34):
		GetString()
	elif lookahead == "'":
		GetAsciiCode()
	elif lookahead == "\\":
		GetComment()
		Next()
	else:
		GetOp()