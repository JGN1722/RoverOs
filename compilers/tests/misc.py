from core.helpers import TestModeError, Type_
from core.parser import ASTNode

from colorama import Fore, Style, init as init_colorama
init_colorama()

def passed():
	print(Fore.GREEN + 'Test Passed' + Style.RESET_ALL)

def failed():
	print(Fore.RED + 'Test Failed' + Style.RESET_ALL)

def warn(msg):
	print(Fore.YELLOW + f'Warning: {msg}' + Style.RESET_ALL)

class TestCase:
	def __init__(self, name, function):
		self.name = name
		self.function = function
		self.state = None
		self.info = {'warn_msg': 'No value returned', 'expected_result': None, 'result': None}
	
	def run(self):
		print(f'Running {self.name}... ', end='')
		self.state = self.function(self.info)
		if self.state == True:
			passed()
		elif self.state == False:
			failed()
			print('Expected result:\n', self.info['expected_result'])
			print('Result:\n', self.info['result'])
		elif self.state == None:
			warn(self.info['warn_msg'])