class SymbolTable:
	def __init__(self):
		self.scopes = []
		self.new_scope()
	
	def new_scope(self):
		self.scopes.append({})
	
	def close_scope(self):
		self.scopes.pop()
	
	def add_symbol(self, name, value):
		self.scopes[-1][name] = value
	
	def get_symbol_value(self, name):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i]:
				return self.scopes[i][name]
		return None
	
	def symbol_exists(self, name):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i].keys():
				return True
		return False
	
	def symbol_in_last_scope(self, name):
		return name in self.scopes[-1]
	
	def symbol_in_first_scope(self, name):
		return name in self.scopes[0]

class IdentSymbolTable(SymbolTable):
	def __init__(self):
		super().__init__()
	
	def add_symbol(self, name, value, function_body=True, stack_offset=0):
		self.scopes[-1][name] = {'value': value, 'body': function_body, 'offset': stack_offset}
	
	def get_symbol_value(self, name):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i]:
				return self.scopes[i][name]['value']
		return None
	
	def get_symbol_body(self, name):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i]:
				return self.scopes[i][name]['body']
		return None
	
	def set_symbol_body(self, name, val):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i]:
				self.scopes[i][name]['body'] = val
	
	def get_symbol_offset(self, name):
		for i in range(len(self.scopes) - 1, -1, -1):
			if name in self.scopes[i]:
				return self.scopes[i][name]['offset']
		return None
	
	def is_symbol_global(self, name):
		return self.symbol_in_first_scope(name)
