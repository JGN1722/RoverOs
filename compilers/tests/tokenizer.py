from tests.misc import *

module = None
name = "tokenizer"

def generic_test(info_dict):
	test_string = """hello there!\nI'm very happy to meet"you# h#e 0x10#0["1 0/20@"""
	expected_result = [
		('x', 'hello', '', 1, 1),
		(' ', ' ', '', 1, 7),
		('x', 'there', '', 1, 8),
		('!', '!', '', 1, 13),
		('\n', '\n', '', 2, 1),
		('x', 'I', '', 2, 2),
		("'", "'", '', 2, 3),
		('x', 'm', '', 2, 4),
		(' ', ' ', '', 2, 5),
		('x', 'very', '', 2, 6),
		(' ', ' ', '', 2, 10),
		('x', 'happy', '', 2, 11),
		(' ', ' ', '', 2, 16),
		('x', 'to', '', 2, 17),
		(' ', ' ', '', 2, 19),
		('x', 'meet', '', 2, 20),
		('"', '"', '', 2, 24),
		('x', 'you', '', 2, 25),
		('#', '#', '', 2, 28),
		(' ', ' ', '', 2, 29),
		('x', 'h', '', 2, 30),
		('#', '#', '', 2, 31),
		('x', 'e', '', 2, 32),
		(' ', ' ', '', 2, 33),
		('0', '010h', '', 2, 34),
		('#', '#', '', 2, 38),
		('0', '0', '', 2, 39),
		('[', '[', '', 2, 40),
		('"', '"', '', 2, 41),
		('0', '1', '', 2, 42),
		(' ', ' ', '', 2, 43),
		('0', '0', '', 2, 44),
		('/', '/', '', 2, 45),
		('0', '20', '', 2, 46),
		('@', '@', '', 2, 48),
		('\x00', '\x00', '', 2, 48)
	]
	
	info_dict['expected_result'] = expected_result
	
	module.file_name = ''
	module.script_directory = ''
	module.source_text = test_string
	
	tokens = module.Tokenize(is_main_file=True)
	
	info_dict['result'] = tokens
	
	return tokens == expected_result

def number_base(info_dict):
	
	module.file_name = ''
	module.script_directory = ''
	
	# No base
	test_string = '010'
	expected_result = [('0', '010', '', 1, 1), ('\x00', '\x00', '', 1, 4)]
	info_dict['expected_result'] = expected_result
	
	module.source_text = test_string
	tokens = module.Tokenize(is_main_file=True)
	info_dict['result'] = tokens
	
	if tokens != expected_result:
		return False
	
	# Hex
	test_string = '0x10'
	expected_result = [('0', '010h', '', 1, 1), ('\x00', '\x00', '', 1, 5)]
	info_dict['expected_result'] = expected_result
	
	module.source_text = test_string
	tokens = module.Tokenize(is_main_file=True)
	info_dict['result'] = tokens
	
	if tokens != expected_result:
		return False
	
	# Bin
	test_string = '0b10'
	expected_result = [('0', '010b', '', 1, 1), ('\x00', '\x00', '', 1, 5)]
	info_dict['expected_result'] = expected_result
	
	module.source_text = test_string
	tokens = module.Tokenize(is_main_file=True)
	info_dict['result'] = tokens
	
	if tokens != expected_result:
		return False
	
	# Invalid bin
	test_string = '0b12'
	expected_error = "unexpected character in digit ( 2 ) in base 2"
	info_dict['expected_result'] = expected_error
	
	try:
		module.source_text = test_string
		tokens = module.Tokenize(is_main_file=True)
		
		info_dict['warn_msg'] = f'The compiler accepted the invalid input {test_string} and outputted {tokens}'
		return None
	
	except TestModeError:
		info_dict['result'] = module.last_err
		
		if module.last_err != expected_error:
			return False
	
	return True

def remove_comments(info_dict):
	
	module.file_name = ''
	module.script_directory = ''
	
	# Single line comment
	test_string = """Hello everyone // This is a greeting\nHey !"""
	expected_result = [
		('x', 'Hello', '', 1, 1),
		(' ', ' ', '', 1, 7),
		('x', 'everyone', '', 1, 8),
		(' ', ' ', '', 1, 16),
		('x', 'Hey', '', 1, 17),
		(' ', ' ', '', 2, 5),
		('!', '!', '', 2, 6),
		('\x00', '\x00', '', 2, 6)
	]
	
	info_dict['expected_result'] = expected_result
	
	module.source_text = test_string
	tokens = module.Tokenize(is_main_file=True)
	
	info_dict['result'] = tokens
	
	if tokens != expected_result:
		return False
	
	# Multi-line comment
	test_string = """Hello everyone /*This is a greeting*/Hey !"""
	expected_result = [
		('x', 'Hello', '', 1, 1),
		(' ', ' ', '', 1, 7),
		('x', 'everyone', '', 1, 8),
		(' ', ' ', '', 1, 16),
		('x', 'Hey', '', 1, 17),
		(' ', ' ', '', 1, 42),
		('!', '!', '', 1, 43),
		('\0', '\0', '', 1, 43)
	]
	
	info_dict['expected_result'] = expected_result
	
	module.source_text = test_string
	tokens = module.Tokenize(is_main_file=True)
	
	info_dict['result'] = tokens
	
	if tokens != expected_result:
		return False
	
	return True

test_cases = [
	TestCase(name='generic test', function=generic_test),
	TestCase(name='number base', function=number_base),
	TestCase(name='remove comments', function=remove_comments)
]
