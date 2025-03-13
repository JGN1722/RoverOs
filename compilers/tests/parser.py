from tests.misc import *

# To help tokenize the input for more readability
import core.tokenizer as tokenizer
import core.preproc as preprocessor

tokenizer.file_name = ''
tokenizer.script_directory = ''

def prepare(input_string):
	tokenizer.source_text = input_string
	preprocessor.token_stream = tokenizer.Tokenize(is_main_file=True)
	return preprocessor.Preprocess()

module = None
name = "parser"

def struct_decl(info_dict):
	
	# Valid declaration
	input = prepare('''
		struct test_struct {
			uint32_t field1, field2;
			uint16_t field3;
		};
	''')
	expected_result = ASTNode(type_='StructDecl', value='test_struct', children=[
		{'name': 'field1', 'type': Type_('uint32_t', 0)},
		{'name': 'field2', 'type': Type_('uint32_t', 0)},
		{'name': 'field3', 'type': Type_('uint16_t', 0)}
	])
	info_dict['expected_result'] = expected_result
	
	module.token_stream = input
	module.Next()
	result = module.StructDecl()
	info_dict['result'] = result
	
	return result == expected_result
	
	# Missing semicolon 
	input = prepare('''
		struct test_struct {
			uint32_t field1, field2;
			uint16_t field3;
		};
	''')
	expected_result = ASTNode(type_='StructDecl', value='test_struct', children=[
		{'name': 'field1', 'type': Type_('uint32_t', 0)},
		{'name': 'field2', 'type': Type_('uint32_t', 0)},
		{'name': 'field3', 'type': Type_('uint16_t', 0)}
	])
	info_dict['expected_result'] = expected_result
	
	module.token_stream = input
	module.Next()
	result = module.StructDecl()
	info_dict['result'] = result
	
	return result == expected_result

test_cases = [
	TestCase(name='structure declaration', function=struct_decl)
]
