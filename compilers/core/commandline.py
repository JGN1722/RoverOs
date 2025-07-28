"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: This module parses the command line and returns the results to the main code
"""

import sys

from core.helpers import *

script_directory = ""

# The messages displayed to the user via the command line
help_message = "RoverC Compiler\n" + "Written for RoverOs\n" + "Author: JGN1722 (Github)\n\n" + "Usage: roverlang.py [--help | --version] [--freestanding] [--test] filename [output_filename]"
version_message = "RoverC Compiler\n" + "Written for RoverOs\n" + "Author: JGN1722 (Github)\n" + "Version: 1.0"

def ParseCommandLine():
	
	# Options are the flags that might affect the compiler behaviour, for example: --freestanding, --help
	# Arguments are the values that the compiler needs to operate, for example a source file name
	options = []
	arguments = []
	
	# "w" format indicates that the output will run under windows
	# "f" format indicates that the output will run on metal, such as when writing OSs
	format = "w"
	
	run_tests = False
	
	# Get the arguments
	for arg in sys.argv[1:]:
		
		# If the argument begins with --, then it's the full name of an option
		if len(arg) >= 2 and arg[0] + arg[1] == "--":
			options.append(arg[2:])
		
		# If the argument begins with -, then it's the short name of an option
		# Note that using short names, a user can pass several options at once
		elif arg[0] == "-":
			for c in arg[1:]:
				if not IsAlpha(c):
					abort("Invalid option character: " + c)
			
			options.extend(arg[1:])
		
		# If it not an option, then it's an argument
		else:
			arguments.append(arg)
	
	# Act following the arguments
	for opt in options:
		if opt == "h" or opt == "help":
			print(help_message)
			sys.exit()
		elif opt == "v" or opt == "version":
			print(version_message)
			sys.exit()
		elif opt == "f" or opt == "freestanding":
			format = "f"
		elif opt == "t" or opt == "test":
			run_tests = True
		else:
			abort("Unrecognized option: " + opt)
	
	# The source file is the first argument
	if len(arguments) >= 1:
		source_file = get_abs_path(arguments[0], os.getcwd())
	else:
		source_file = ""
	
	# The output path is the second argument, if specified
	if len(arguments) >= 2:
		output_file = get_abs_path(arguments[1], os.getcwd())
	
	# If nothing is specified, deduce the output path by appending the extension corresponding to the format
	elif format == "w":
		output_file = convert_to_ext(get_abs_path(source_file, script_directory), 'exe')
	elif format == "f":
		output_file = convert_to_ext(get_abs_path(source_file, script_directory), 'bin')
	
	return source_file, output_file, format, run_tests

# Error functions
def abort(s):
	print("Error: " + s, file=sys.stderr)
	sys.exit(-1)
