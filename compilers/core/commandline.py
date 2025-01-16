"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: This module parses the command line and returns the results to the main code
"""

import sys

from core.helpers import *

script_directory = ""

help_message = "RoverC Compiler\n" + "Written for RoverOs\n" + "Author: JGN1722 (Github)\n\n" + "Usage: roverlang.py [--help | --version] [--freestanding] filename [output_filename]"
version_message = "RoverC Compiler\n" + "Written for RoverOs\n" + "Author: JGN1722 (Github)\n" + "Version: 1.0"

def ParseCommandLine():
	global source_file, output_file, debug_mode
	
	options = []
	arguments = []
	
	format = "w" # Compilation for running under windows is the default
	
	for arg in sys.argv[1:]:
		if len(arg) >= 2 and arg[0] + arg[1] == "--":
			options.append(arg[2:])
		elif arg[0] == "-":
			for c in arg[1:]:
				if not IsAlpha(c):
					abort("Invalid option character: " + c)
			
			options.extend(arg[1:])
		else:
			arguments.append(arg)
	
	for opt in options:
		if opt == "h" or opt == "help":
			print(help_message)
			sys.exit()
		elif opt == "v" or opt == "version":
			print(version_message)
			sys.exit()
		elif opt == "f" or opt == "freestanding":
			format = "f" # If this is specified, the format is "freestanding", for running on bare metal
		else:
			abort("Unrecognized option: " + opt)
	
	if len(arguments) >= 1:
		source_file = get_abs_path(arguments[0], os.getcwd())
	else:
		source_file = ""
	
	if len(arguments) >= 2:
		output_file = get_abs_path(arguments[1], os.getcwd())
	elif format == "w":
		output_file = convert_to_ext(get_abs_path(source_file, script_directory), 'exe')
	elif format == "f":
		output_file = convert_to_ext(get_abs_path(source_file, script_directory), 'bin')
	
	return source_file, output_file, format

# Error functions
def abort(s):
	print("Error: " + s, file=sys.stderr)
	sys.exit(-1)

def Warning(s):
	print("Warning: " + s)
