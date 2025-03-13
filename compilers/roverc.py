"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
"""

from colorama import Fore, Style, init as init_colorama
import subprocess
import sys
import os

script_directory = os.path.dirname(os.path.abspath(__file__))
include_directory = script_directory + '/ROVERINCLUDE/'

# Import the needed files
from core.helpers import *
import core.commandline as commandline
import core.transpiler as transpiler
import core.optimizer as optimizer
import core.tokenizer as tokenizer
import core.preproc as preproc
import core.parser as parser

commandline.script_directory = script_directory
tokenizer.script_directory = script_directory
preproc.script_directory = script_directory

preproc.include_directory = include_directory

# Import the test modules
import tests.transpiler as test_transpiler
import tests.tokenizer as test_tokenizer
import tests.preproc as test_preproc
import tests.parser as test_parser

test_transpiler.module = transpiler
test_tokenizer.module = tokenizer
test_preproc.module = preproc
test_parser.module = parser


def compile(asm):
	global source_file, output_file
	
	with open(script_directory + "\\output.asm", "w") as file:
		file.write(asm)
	
	subprocess.run([script_directory + "\\fasm.exe",script_directory + "\\output.asm",output_file])

# Error functions
def abort(s):
	print("Error: " + s, "(file", file_name, "line", line_number, "character", character_number, ")", file=sys.stderr)
	sys.exit()

# Output functions
file_name = ""
line_number = 0
character_number = 0
source_file = ""
output_file = ""

# A debug routine to dump the AST
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

def run_test_suite():
	passed = 0
	failed = 0
	warnings = 0
	for test_suite in [test_tokenizer, test_preproc, test_parser, test_transpiler]:
		
		# Turn on testing mode to raise exceptions instead of exiting
		test_suite.module.TEST_MODE = True
		
		print(f'Running tests for {test_suite.name}...')
		if test_suite.test_cases == []:
			print("No test cases found\n")
			continue
		
		for test_case in test_suite.test_cases:
			test_case.run()
			if test_case.state == True:
				passed += 1
			elif test_case.state == False:
				failed += 1
			elif test_case.state == None:
				warnings += 1
		print()
	
	print('=' * 30)
	print(Fore.GREEN, 'Passed tests:', Style.RESET_ALL, passed)
	print(Fore.RED, 'Failed tests:', Style.RESET_ALL, failed)
	print(Fore.YELLOW, 'Warnings:', Style.RESET_ALL, warnings)
	print('=' * 30)

# Main code
if __name__ == "__main__":
	# Check the command line arguments and options
	source_file, output_file, format, run_tests = commandline.ParseCommandLine()
	
	if run_tests:
		run_test_suite()
		sys.exit()
	
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
	transpiler.transpile()
	asm = transpiler.GetFormattedOutput(format)
	
	# Optimize the output
	asm = optimizer.Optimize(asm)
	
	# Assemble the program
	compile(asm)

