"""
RoverC Compiler
Written for RoverOs
Author: JGN1722 (Github)
Description: The core of the typing system of roverc
"""

from core.helpers import *

import copy

class Type_:
	def __init__(self):
		...
	
	def weak_compat(self, other):
		return False
	
	def is_number(self):
		return False
	
	def is_pointer(self):
		return False
	
	def is_void(self):
		return False
	
	def is_array(self):
		return False
	
	def is_struct(self):
		return False
	
	def compatible(self, other):
		return self.weak_compat(other) and other.weak_compat(self)

class NumberType(Type_):
	def __init__(self, size, signed=True, const=False):
		super().__init__()
		
		self.size = size
		self.const = const
		self.signed = signed
	
	def weak_compat(self, other):
		return True
	
	def is_number(self):
		return True
	
	def __eq__(self, other):
		return isinstance(other, self.__class__) and other.is_number and self.size == other.size and self.const == other.const and self.signed == other.signed
	
	def __repr__(self):
		return f'NumberType(size={self.size}, const={self.const}, signed={self.signed})'

class VoidType(Type_):
	def __init__(self):
		super().__init__()
	
	def weak_compat(self, other):
		return other.is_void()
	
	def is_void(self):
		return True
	
	def __eq__(self, other):
		return isinstance(other, self.__class__) and other.is_void()
	
	def __repr__(self):
		return f'VoidType()'

class PointerType(Type_):
	def __init__(self, arg, const=False):
		super().__init__()
		self.arg = arg
		self.const = const
		self.size = 4 # Compile for 32 bits by default, so pointer is DWORD
	
	def weak_compat(self, other):
		return other.is_number() or other.is_pointer() and self.arg.compatible(other.arg)
	
	def is_pointer(self):
		return True
	
	def __eq__(self, other):
		return isinstance(other, self.__class__) and other.is_pointer() and self.arg == other.arg and self.const == other.const
	
	def __repr__(self):
		return f'PointerType(arg={self.arg}, const={self.const})'

class ArrayType(Type_):
	def __init__(self, arg, len):
		super().__init__()
		self.arg = arg
		self.len = len
		if not isinstance(arg, StructType):
			self.size = arg.size * int(len)
	
	def compatible(self, other):
		return other.is_array() and self.arg.compatible(other.arg) and (self.n is None or other.n is None or self.n == other.n)
	
	def is_array(self):
		return True
	
	def __eq__(self, other):
		return isinstance(other, self.__class__) and other.is_array() and self.arg == other.arg and self.len == other.len
	
	def __repr__(self):
		return f'ArrayType(arg={self.arg}, len={self.len})'

class FunctionType(Type_):
	def __init__(self, args, ret):
		super().__init__()
		self.args = args
		self.ret = ret
	
	def weak_compat(self, other):
		if not isinstance(other, self.__class__):
			return False
		if not other.is_function():
			return False
		elif not self.ret.compatible(other.ret):
			return False
		elif not self.no_info and not other.no_info:
			if len(self.args) != len(other.args):
				return False
			elif any(not a1.compatible(a2) for a1, a2 in zip(self.args, other.args)):
				return False
		
		return True
	
	def is_function(self):
		return True
	
	def __eq__(self, other):
		return other.is_function() and self.ret == other.ret and (arg['type'] == other_arg['type'] for arg, other_arg in zip(self.args, other.args))
	
	def __repr__(self):
		return f'FunctionType(args={self.args}, ret={self.ret})'

class StructType(Type_):
	def __init__(self, name):
		super().__init__()
		self.name = name
	
	def is_struct(self):
		return True
	
	def __eq__(self, other):
		return isinstance(other, self.__class__) and other.is_struct() and self.name == other.name
	
	def __repr__(self):
		return f'StructType(name={self.name})'

class EmptyType(Type_):
	def make_function(self, args, ret):
		self.__class__ = FunctionType
		self.__init__(args, ret)
	
	def make_array(self, arg, len):
		self.__class__ = ArrayType
		self.__init__(arg, len)

unsig_char_max = 255
int_max = 2147483647
int_min = -2147483648
long_max = 9223372036854775807
long_min = -9223372036854775808