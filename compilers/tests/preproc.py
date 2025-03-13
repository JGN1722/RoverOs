from tests.misc import *

# To help tokenize the input for more readability
import core.tokenizer as tokenizer

tokenizer.file_name = ''
tokenizer.script_directory = ''

module = None
name = "preprocessor"

def error_directive(info_dict):
	tokenizer.source_text = 'a b c #error test test2'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	expected_error = 'test test2'
	info_dict['expected_result'] = expected_error
	
	try:
		module.Preprocess()
		
		info_dict['warn_msg'] = 'The compiler did not send an error on error directive'
		return None
	except TestModeError:
		info_dict['result'] = module.last_err
		
		return module.last_err == expected_error

def undef_directive(info_dict):
	expected_result = {}
	for macro in module.defined_macros:
		expected_result[macro] = module.defined_macros[macro]
	info_dict['expected_result'] = expected_result
	
	module.defined_macros['MACRO'] = [[], []]
	tokenizer.source_text = '#undef MACRO\n'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	
	module.Preprocess()
	
	info_dict['result'] = module.defined_macros
	return module.defined_macros == expected_result

def define_directive(info_dict):
	
	# Classic definition
	expected_result = {}
	for macro in module.defined_macros:
		expected_result[macro] = module.defined_macros[macro]
	expected_result['MACRO'] = [[(' ', ' '), ('x', 'Hello'), (' ', ' '), ('x', 'there')], []]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'a b c #define MACRO Hello there'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	module.Preprocess()
	
	info_dict['result'] = module.defined_macros
	
	if module.defined_macros != expected_result:
		return False
	
	# Classic expansion
	expected_result = [
		('x', 'abcde', '', 1, 1),
		('x', 'Hello', '', 1, 8),
		('x', 'there', '', 1, 8),
		('x', 'abcde', '', 1, 14),
		('\0', '\0', '', 1, 18)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'abcde MACRO abcde'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	# Redefinition
	expected_error = 'Macro redefinition: MACRO'
	info_dict['expected_result'] = expected_error
	
	tokenizer.source_text = 'abc #define MACRO Hey there'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	
	try:
		module.Preprocess()
		
		info_dict['warn_msg'] = 'The compiler did not send an error on macro redefinition'
		return None
	
	except TestModeError:
		info_dict['result'] = module.last_err
		
		if module.last_err != expected_error:
			return False
	
	# Definition with arguments
	expected_result = {}
	for macro in module.defined_macros:
		expected_result[macro] = module.defined_macros[macro]
	expected_result['MACRO2'] = [
		[(' ', ' '), ('x', 'Hello'), (' ', ' '), ('x', 'a'), (' ', ' '), ('x', 'there'), (' ', ' '), ('x', 'b')],
		['a', 'b']
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'abc#define MACRO2(a,b) Hello a there b'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	module.Preprocess()
	
	info_dict['result'] = module.defined_macros
	
	if module.defined_macros != expected_result:
		return False
	
	# Expansion with arguments
	expected_result = [
		('x', 'abcde', '', 1, 1),
		('x', 'Hello', '', 1, 8),
		('x', 'x', '', 1, 8),
		('x', 'there', '', 1, 8),
		('x', 'y', '', 1, 8),
		('x', 'abcde', '', 1, 21),
		('\0', '\0', '', 1, 25)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'abcde MACRO2(x, y) abcde'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	return True

def ifdef_directive(info_dict):
	
	# Existing macro
	expected_result = [
		('x', 'a', '', 1, 1),
		('x', 'b', '', 1, 4),
		('x', 'c', '', 1, 6),
		('x', 'd', '', 3, 2),
		('x', 'e', '', 3, 4),
		('x', 'f', '', 3, 6),
		('x', 'g', '', 4, 2),
		('x', 'h', '', 4, 4),
		('x', 'i', '', 4, 6),
		('\x00', '\x00', '', 4, 6)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'a b c\n#ifdef _ROVERC\nd e f#endif\ng h i'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	# Non-existing macro
	expected_result = [
		('x', 'a', '', 1, 1),
		('x', 'b', '', 1, 4),
		('x', 'c', '', 1, 6),
		('x', 'g', '', 4, 2),
		('x', 'h', '', 4, 4),
		('x', 'i', '', 4, 6),
		('\x00', '\x00', '', 4, 6)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'a b c\n#ifdef NON_EXISTING_MACRO\nd e f#endif\ng h i'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	return True

def ifndef_directive(info_dict):
	
	# Existing macro
	expected_result = [
		('x', 'a', '', 1, 1),
		('x', 'b', '', 1, 4),
		('x', 'c', '', 1, 6),
		('x', 'g', '', 4, 2),
		('x', 'h', '', 4, 4),
		('x', 'i', '', 4, 6),
		('\x00', '\x00', '', 4, 6)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'a b c\n#ifndef _ROVERC\nd e f#endif\ng h i'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	# Non-existing macro
	expected_result = [
		('x', 'a', '', 1, 1),
		('x', 'b', '', 1, 4),
		('x', 'c', '', 1, 6),
		('x', 'd', '', 3, 2),
		('x', 'e', '', 3, 4),
		('x', 'f', '', 3, 6),
		('x', 'g', '', 4, 2),
		('x', 'h', '', 4, 4),
		('x', 'i', '', 4, 6),
		('\x00', '\x00', '', 4, 6)
	]
	info_dict['expected_result'] = expected_result
	
	tokenizer.source_text = 'a b c\n#ifndef NON_EXISTING_MACRO\nd e f#endif\ng h i'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	tokens = module.Preprocess()
	
	info_dict['result'] = tokens
	if tokens != expected_result:
		return False
	
	return True

def include_directive(info_dict):
	pass

def unknown_directive(info_dict):
	tokenizer.source_text = 'a b c #invalid_directive_name'
	module.token_stream = tokenizer.Tokenize(is_main_file=True)
	expected_error = 'Unknown directive: invalid_directive_name'
	info_dict['expected_result'] = expected_error
	
	try:
		module.Preprocess()
		
		info_dict['warn_msg'] = 'The compiler did not send an error when encountering an unknown directive'
		return None
	
	except TestModeError:
		info_dict['result'] = module.last_err
		
		return module.last_err == expected_error

test_cases = [
	TestCase(name='error directive', function=error_directive),
	TestCase(name='undef directive', function=undef_directive),
	TestCase(name='define directive', function=define_directive),
	TestCase(name='ifdef directive', function=ifdef_directive),
	TestCase(name='ifndef directive', function=ifndef_directive),
	TestCase(name='include directive', function=include_directive),
	TestCase(name='unknown directive', function=unknown_directive)
]