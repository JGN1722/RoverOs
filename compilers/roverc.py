"""
RoverLang Compiler
Written for RoverOs
Author: JGN1722 (Github)
"""

import subprocess
import sys
import os

script_directory = os.path.dirname(os.path.abspath(__file__))

# Import the needed files
from core.helpers import *
import core.commandline as commandline
import core.transpiler as transpiler
import core.tokenizer as tokenizer
import core.preproc as preproc
import core.parser as parser

commandline.script_directory = script_directory
tokenizer.script_directory = script_directory
preproc.script_directory = script_directory

debug_mode = 0

def compile(asm):
	global source_file, output_file
	
	with open(script_directory + "\\output.asm", "w") as file:
		file.write(asm)
	
	subprocess.run([script_directory + "\\fasm.exe",script_directory + "\\output.asm",output_file])

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

# Output functions

file_name = ""
line_number = 0
character_number = 0
source_file = ""
output_file = ""

def dbg():
	print("token: ", token)
	print("value: ", value)

#Pretty printing the AST
tab_number = 0

def print_node(node):
	global tab_number
	
	print("\t" * tab_number,"Node",node.type,"with value",node.value)
	if node.children != []:
		tab_number += 1
		
		for child in node.children:
			try:
				print_node(child)
			except:
				print("\t" * tab_number,child)
		
		tab_number -= 1

# Main code
if __name__ == "__main__":
	# Check the command line arguments and options
	source_file, output_file = commandline.ParseCommandLine()
	
	# Read the source
	if source_file == "":
		abort("source file not specified")
	source_text = ReadSourceText(source_file, script_directory)
	
	file_name = source_file
	
	# Tokenize the program
	tokenizer.file_name = file_name
	tokenizer.source_text = source_text
	token_stream = tokenizer.Tokenize(is_main_file=True)
	
	# Extend the macros, include the files and such
	preproc.token_stream = token_stream
	token_stream = preproc.Preprocess()
	
	# Produce the AST
	parser.token_stream = token_stream
	AST = parser.ProduceAST()
	
	# Generate the assembly from the AST
	transpiler.AST = AST
	asm = transpiler.transpile()
	# print(asm)
	
	# Begin compiling
	compile(asm)
