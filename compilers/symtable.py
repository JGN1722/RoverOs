IDENTIFIER_VARIABLE = 1
IDENTIFIER_FUNCTION = 2

# The symbol table is an array of symbol classes
global_symbol_table = []
local_symbol_table = []
struct_table = []
local_param_number = 0

class Symbol():
	def __init__(self, name, type=IDENTIFIER_VARIABLE, datatype="INT", attr1=0, attr2=0):
		self.name = name
		self.type = type
		self.datatype = datatype
		self.attr1 = attr1
		self.attr2 = attr2
	
	def __repr__(self):
		return str({'name': self.name, 'datatype': self.datatype})

def add_global_symbol(name, type=IDENTIFIER_VARIABLE, datatype="INT", attr1=0, attr2=0):
	global_symbol_table.append(Symbol(name, type, datatype, attr1, attr2))

def add_local_symbol(name, type="variable", datatype="INT", attr1=0, attr2=0):
	if IsKeyword(name):
		abort("reserved keyword used as identifier ( " + name + ")")
	if IsType(name) or is_local_symbol(name):
		abort("redefined identifier ( " + name + ")")
	local_symbol_table.append(Symbol(name, type, datatype, attr1, attr2))

def remove_local_symbol(name):
	global local_symbol_table
	
	if not is_local_symbol(name):
		return
	del local_symbol_table[get_local_symbol_offset(name)]

def is_global_symbol(name):
	return any(obj.name == name for obj in global_symbol_table)

def is_local_symbol(name):
	return any(obj.name == name for obj in local_symbol_table)

def clear_local_symbol_table():
	local_symbol_table = []

def get_local_symbol_offset(n):
	for i in range(len(local_symbol_table)):
		if local_symbol_table[i].name == n:
			return i
	return -1

def get_global_symbol_offset(n):
	for i in range(len(global_symbol_table)):
		if global_symbol_table[i].name == n:
			return i
	return -1

def get_data_type(n):
	global global_symbol_table, local_symbol_table
	
	if is_global_symbol(n):
		return global_symbol_table[get_global_symbol_offset(n)].datatype
	elif is_local_symbol(n):
		return local_symbol_table[get_local_symbol_offset(n)].datatype
	return ""

def dump_local_table():
	print([str(obj) for obj in local_symbol_table])

def clear_local_symbol_table():
	global local_symbol_table
	local_symbol_table = []

def get_symbol_type(n):
	global global_symbol_table, local_symbol_table
	
	if is_global_symbol(n):
		return global_symbol_table[get_global_symbol_offset(n)].type
	elif is_local_symbol(n):
		return local_symbol_table[get_local_symbol_offset(n)].type
	return None

def is_struct(n):
	return any(s["name"] == n for s in struct_table)

def add_struct(n):
	global struct_table
	
	if not is_struct(n):
		struct_table.append({"name": n, "attributes": []})

def get_struct_number(n):
	for i in range(len(struct_table)):
		if struct_table[i]["name"] == n:
			return i
	return -1

def add_member(n, type, name):
	global struct_table
	
	i = get_struct_number(n)
	if struct_table[i]["attributes"] == []:
		total_offset = 0
	else:
		total_offset = struct_table[i]["attributes"][-1][2] + SizeOf(struct_table[i]["attributes"][-1][1])
	struct_table[i]["attributes"].append((name, type, total_offset))

def get_member_info(n, attr):
	global struct_table
	
	i = get_struct_number(n)
	for a in struct_table[i]["attributes"]:
		if a[0] == attr:
			return a