"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: This module parses the command line and returns the results to the main code
"""

import sys

from core.helpers import *

script_directory = ""

def ParseCommandLine():
	global source_file, output_file, debug_mode
	
	options = []
	arguments = []
	
	for arg in sys.argv[1:]:
		if arg[0] == "-":
			for c in arg[1:]:
				if not IsAlpha(c):
					abort("Invalid option character: " + c)
			
			options.extend(arg[1:])
		else:
			arguments.append(arg)
	
	for opt in options:
		if opt == "h":
			print("RoverLang Compiler\n" +
			      "Written for RoverOs\n" + 
			      "Author: JGN1722 (Github)\n\n" +
			      "Usage: roverlang.py [-h | -v] filename [output_filename]")
			sys.exit()
		elif opt == "v":
			print("RoverLang Compiler\n" +
			      "Written for RoverOs\n" + 
			      "Author: JGN1722 (Github)\n" +
			      "Version: 1.0")
			sys.exit()
		else:
			abort("Unrecognized option: " + opt)
	
	if len(arguments) >= 1:
		source_file = arguments[0]
	else:
		source_file = ""
	
	if len(arguments) >= 2:
		output_file = arguments[1]
	else:
		output_file = convert_to_bin(get_abs_path(source_file, script_directory))
	
	return source_file, output_file

# Error functions
def abort(s):
	print("Error: " + s, file=sys.stderr)
	sys.exit()

def Warning(s):
	print("Warning: " + s)
