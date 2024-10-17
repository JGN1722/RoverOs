keyword_list = [
	'INT',
	'MAIN',
	'ASM',
	'WORD',
	'BYTE'
]

def IsAddop(c):
	return c == "+" or c == "-"

def IsBitWiseOp(t):
	return t == "SHL" or t == "SHR" or t == "SAR" or t == "SAL"

def IsMulop(c):
	return c == "*" or c == "/" or c == "%"

def IsRelop(c):
	return c == "<" or c == ">" or c == "=" or c == "!"

def IsOrop(c):
	return c == "|" or c == "~" or c == "OR" or c == "XOR"

def IsType(t):
	return t == "INT"

def IsSize(t):
	return t == "DWORD" or t == "WORD" or t == "BYTE"

def IsKeyword(t):
	return t in keyword_list

def FormatString(L, s):
	print("formatting",s)
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
	
	print("returning",L + " db " + r)
	return L + " db " + r
