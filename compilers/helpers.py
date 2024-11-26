import os

keyword_list = [
	'INT',
	'MAIN',
	'ASM',
	'DWORD',
	'WORD',
	'BYTE'
]

def IsAlpha(c):
	return ord(c.upper()) >= 65 and ord(c.upper()) <= 90 or c == "_"

def IsDigit(c):
	return ord(c) >= 48 and ord(c) <= 57

def IsHexDigit(c):
	return (ord(c) >= 48 and ord(c) <= 57) or (ord(c.upper()) >= ord("A") and ord(c.upper()) <= ord("F"))

def IsAlnum(c):
	return IsAlpha(c) or IsDigit(c)

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

def SizeOf(t):
	if t == "BYTE":
		return 1
	elif t == "WORD":
		return 2
	elif t == "DWORD" or t == "INT":
		return 4

def IsKeyword(t):
	return t in keyword_list

def FormatString(L, s):
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
	
	return L + " db " + r

def get_abs_path(path, base_path):
	if path[:3][1:] == ":\\":
		abs_path = path
	else:
		abs_path = base_path + "\\" + path
	
	return os.path.realpath(abs_path)

def ReadSourceText(path, base_directory):
	abs_path = get_abs_path(path, base_directory)
		
	if not os.path.isfile(abs_path):
		abort("source file not found (" + abs_path + ")")
	
	file = open(abs_path)
	source_text = file.read()
	file.close()
	
	return source_text

def convert_to_bin(file_path):
	# Split the file path into base and extension
	base, ext = os.path.splitext(file_path)
	
	# If there's no extension, just append .bin
	if ext == '':
		return file_path + '.bin'
		
	# If an extension exists, replace it with .bin
	return base + '.bin'
