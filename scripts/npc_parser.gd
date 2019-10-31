extends Node

var script_stack = [] # stack of an instructions to execute, basic LIFO in nature
var wait_flag = false # flag that signalizes wait for an input(if any)

var npc_reference
var player_reference

var dialogue_panel # reference to a dialogue panel

func npc_print(strings, player):
	# Dictionary used to mark all of the tags
	# Note that attributes are build each time that
	# npc_print is called. Data could change, so it
	# needs to be done like that
	var attributes_dictionary = {"npc_name": npc_reference.given_name,
								"npc_occupation": npc_reference.occupation,
								"npc_title": npc_reference.title,
								"npc_glyph": npc_reference.get_node("Label").text,
								"npc_glyph_color": '#' + npc_reference.get_node("Label").get_color("font_color").to_html(false),
								"player_hp": player.hp}
	
	var formatted_strings = []
	
	for string in strings:
		string.format(attributes_dictionary)
		formatted_strings.append(string)

	player.input_mode = player.INPUT_DIALOGUE
	dialogue_panel.dialogue_print(formatted_strings)

#initialize needed functions
func initialize(dialogue_panel):
	self.dialogue_panel = dialogue_panel

#initialize parsing by giving NPC's name
func parse(npc_ref, player_ref):
	player_reference = player_ref
	npc_reference = npc_ref
	
	var dialogue_file = File.new()

	match(dialogue_file.open("res://Dialogues/" + npc_ref.name + ".json",File.READ)):
		OK:
			var dialogue_string = dialogue_file.get_as_text()
			dialogue_file.close()
			var parse_result = JSON.parse(dialogue_string)
			if(parse_result.error == OK):
				var dialogue_script = parse_result.result
				script_stack = dialogue_script["stack"]
			else:
				print("Error parsing JSON.", parse_result.error_string, parse_result.error_line)
		ERR_CANT_OPEN:
			print("No such NPC in database")

# clear interpreter
func finish():
	script_stack = null
	
func _process(delta):
	if(script_stack.size() > 0):
		if(!wait_flag):
			_pop()
		else:
			pass

# pop a instruction from stack and call it
func _pop():
	_call(script_stack[0])
	
	if(script_stack.empty()):
		finish()
		return
	
	script_stack.pop_front()
	
func _call(function):
	print(function)
	var keys = function.keys()
	if("if" in keys):
		# conditional statement
		# if "if" expression is true, "then" is executed, else "else" is executed
		# notice that "if","then" and "else" are given as key-value pairs, not as array
		if(Eval.eval(function["if"])):
			_call(function["then"])
		else:
			_call(function["else"])
	elif("choice" in keys):
		# switch/case like instruction intended for dialogue branches
		# choice is a block, consisting of:
		# "choice": [choices] -> array of strings that represent choices. Their names are also printed out in dialogue.
		# keys of choices in previous key, values are sub-stacks
		dialogue_panel.enable_choices(function["choice"])
		self.wait_flag = true
	elif("print" in keys):
		# what function called print can do?
		# obviously, it prints text onto dialogue textbox
		# argument is an array of strings, pause in dialogue is inserted after each one
		self.wait_flag = true
		npc_print(function["print"],player_reference)
	elif("pre_print" in keys):
		# pre-print works like ordinary print, but adds additional string at the beggining of all strings.
		# pre_print is smart, it notices "!CLR" and other controls
		# args are: [pre_string,[strings]]
		# notice that no spaces are added after pre_string
		var prepared_strings = []
		var clr_flag = false

		for string in function["pre_print"][1]:
			if(!clr_flag):
				prepared_strings.append(function["pre_print"][0] + string)
				clr_flag = true
			elif(string != "!CLR"):
				prepared_strings.append(string)
			else:
				prepared_strings.append(string)
				clr_flag = false

		self.wait_flag = true
		npc_print(prepared_strings, player_reference)
	elif("pre_print_raw" in keys):
		# like pre_print, but doesn't care about "!CLR" and such
		# args are: [pre_string,[strings]]
		# notice that no spaces are added after pre_string
		var prepared_strings = []

		for string in function["pre_print_raw"][1]:
			prepared_strings.append(function["pre_print_raw"][0] + string)
			
		self.wait_flag = true
		npc_print(prepared_strings, player_reference)