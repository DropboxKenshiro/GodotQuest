extends Node

var script_stack = [] # stack of an instructions to execute, basic LIFO in nature
var wait_flag = false # flag that signalizes wait for an input(if any)

var npc_reference
var player_reference

var function_state # function reference for interpreting yields

var dialogue_panel # reference to a dialogue panel

func string_parse(strings):
	# Dictionary used to mark all of the tags
	# Note that attributes are build each time that
	# npc_print is called. Data could change, so it
	# needs to be done like that
	var attributes_dictionary = {"npc_name": npc_reference.given_name,
								"npc_occupation": npc_reference.occupation,
								"npc_title": npc_reference.title,
								"player_hp": player_reference.hp}
	
	var formatted_strings = []
	
	for string in strings:
		formatted_strings.append(string.format(attributes_dictionary))
	formatted_strings.append("!CLR") # clear screen after a print statement

	dialogue_panel.dialogue_add(formatted_strings)

func _ready():
	self.set_process(false) # disable interpretation

#initialize needed functions
func initialize(dialogue_panel):
	self.dialogue_panel = dialogue_panel

#initialize parsing by giving NPC's name
func parse(npc_ref, player_ref):
	player_reference = player_ref
	npc_reference = npc_ref
	
	var dialogue_file = File.new()

	match(dialogue_file.open("res://Dialogues/" + npc_ref.npc_id + ".json",File.READ)):
		OK:
			var dialogue_string = dialogue_file.get_as_text()
			dialogue_file.close()
			var parse_result = JSON.parse(dialogue_string)
			if(parse_result.error == OK):
				print("JSON parsing done correctly!")
				var dialogue_script = parse_result.result
				script_stack = dialogue_script["stack"]
			else:
				print("Error parsing JSON.", parse_result.error_string, parse_result.error_line)
		ERR_CANT_OPEN:
			print("No such NPC in database")
			
	self.set_process(true)
		
func _process(delta):
	if(script_stack.size() != 0):
		if(!wait_flag):
			function_state = _call(script_stack.pop_front())
	else:
		finish()

# clear interpreter
func finish():
	script_stack = []
	self.set_process(false)
	
# add a substack onto main instruction stack. Used for if, choice and others like those
func _add_sub(sub: Array):
	 # we're reversing so instructions would be in correct order from top of the stack
	var sub_i = sub
	sub_i.invert()
	
	for instruction in sub_i:
		script_stack.push_front(instruction)

func _call(args):
	print(args)
	var keys = args.keys()
	if("null" in keys):
		# null statement does nothing. It could have anything as a value.
		# used for testing
		pass
	elif("if" in keys):
		# conditional statement
		# form: {"if": *condition*, "then": [*substack if true*], "else": [*substack if false*]}
		# if "if" expression is true, "then" is executed, else "else" is executed
		# notice that "if","then" and "else" are given as key-value pairs, not as array
		if(Eval.eval(args["if"], npc_reference, player_reference)):
			_add_sub(args["then"])
		else:
			_add_sub(args["else"])
	elif("choice" in keys):
		# switch/case like instruction intended for dialogue branches
		# choice is a block, consisting of:
		# "choice": [choices] -> array of strings that represent choices. Their names are also printed out in dialogue.
		# keys of choices in previous key, values are sub-stacks
		# TODO: this needed total rework.
		pass
	elif("print" in keys):
		# what function called print can do?
		# obviously, it prints text onto dialogue textbox
		# form: {"print": [*string1*, ...]}
		# argument is an array of strings, pause in dialogue is inserted after each one
		# after end of an statement, dialogue box is cleared
		# technically, "!CLR" is appended at the end
		string_parse(args["print"])