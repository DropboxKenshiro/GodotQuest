extends StaticBody2D

class_name NPC

# enum determining type of activation
enum ActivationType {ACTIVATE_WALK_INTO, ACTIVATE_TRIGGER}

var event_trigger # reference to collider that represents trigger area. If null, it's the default collider

onready var dialogue_panel = $"../MainCamera/UI/DialoguePanel"

var dialogue_script

export (String) var given_name # given name of an NPC. Could be blank
export (String) var occupation # occupation, like a Shopkeeper
export (String) var title # honorary title of an NPC
export (String) var npc_id # id that is used for searches etc.

export (ActivationType) var activation_type # determines how event is activated

func npc_print(strings, player):
	# Dictionary used to mark all of the tags
	# Note that attributes are build each time that
	# npc_print is called. Data could change, so it
	# needs to be done like that
	var attributes_dictionary = {"npc_name": given_name,
								"npc_occupation": occupation,
								"npc_title": title,
								"npc_glyph": $"Label".text,
								"npc_glyph_color": '#' + $"Label".get_color("font_color").to_html(false),
								"player_hp": player.hp}
	
	var formatted_strings = PoolStringArray()
	
	for dialogue_part in strings:
		formatted_strings.append(dialogue_part.format(attributes_dictionary))
	
	player.input_mode = player.INPUT_DIALOGUE
	dialogue_panel.dialogue_print(formatted_strings)

func choice_print(choices):
	dialogue_panel.enable_choices(PoolStringArray(choices))

func npc_event(player):
	npc_parse(dialogue_script, player)

func npc_parse(script, player):
	for instruction in script["stack"]:
		self.npc_call(instruction,player)
		
func npc_call(instruction, player):
	var exec = instruction.keys()[0]
	match exec:
		"if":
			# conditional statement
			# if "if" expression is true, "then" is executed, else "else" is executed
			# notice that "if","then" and "else" are given as key-value pairs, not as array
			if(Eval.eval(instruction["if"])):
				npc_call(instruction["then"],player)
			else:
				npc_call(instruction["else"],player)
		"choice":
			# switch/case like instruction intended for dialogue branches
			# choice is a block, consisting of:
			# "choice": [choices] -> array of strings that represent choices. Their names are also printed out in dialogue.
			# keys of choices in previous key, values are sub-stacks
			choice_print(instruction["choice"])
		"print":
			# what function called print can do?
			# obviously, it prints text onto dialogue textbox
			# argument is an array of strings, pause in dialogue is inserted after each one
			npc_print(instruction["print"],player)
		"pre_print":
			# pre-print works like ordinary print, but adds additional string at the beggining of all strings.
			# pre_print is smart, it notices "!CLR" and other controls
			# args are: [pre_string,[strings]]
			# notice that no spaces are added after pre_string
			var prepared_strings = PoolStringArray()
			var clr_flag = false
			
			for string in instruction["pre_print"][1]:
				if(!clr_flag):
					prepared_strings.append(instruction["pre_print"][0] + string)
					clr_flag = true
				elif(string != "!CLR"):
					prepared_strings.append(string)
				else:
					prepared_strings.append(string)
					clr_flag = false
					
				npc_print(prepared_strings, player)
		"pre_print_raw":
			# like pre_print, but doesn't care about "!CLR" and such
			# args are: [pre_string,[strings]]
			# notice that no spaces are added after pre_string
			var prepared_strings = PoolStringArray()
			
			for string in instruction["pre_print_raw"][1]:
				prepared_strings.append(instruction["pre_print_raw"][0] + string)
				npc_print(prepared_strings, player)
		

func _ready():
	var dialogue_file = File.new()
	
	match(dialogue_file.open("res://Dialogues/" + npc_id + ".json",File.READ)):
		OK:
			var dialogue_string = dialogue_file.get_as_text()
			dialogue_file.close()
			var parse_result = JSON.parse(dialogue_string)
			if(parse_result.error == OK):
				dialogue_script = parse_result.result
			else:
				print("Error parsing JSON.", parse_result.error_string, parse_result.error_line)
			
			print(dialogue_script)
		ERR_CANT_OPEN:
			print("No such NPC in database")

	
