"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: This module unifies the error reporting of the compiler
"""

import sys

from core.helpers import *

warnings = []
last_err = ''

def abort(msg):
	global last_err
	
	last_err = msg
	print('Error:', msg, file=sys.stderr)
	sys.exit(-1)

def warning(msg):
	warnings.append(msg)
	print('Warning:', msg)