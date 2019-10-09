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

func npc_print(string, player):
	# Dictionary used to mark all of the tags
	# Note that attributes are build each time that
	# npc_print is called. Data could change, so it
	# needs to be done like that
	var attributes_dictionary = {"npc_name": given_name,
								"npc_occupation": occupation,
								"npc_title": title,
								"npc_glyph": $"Label".text,
								"player_hp": player.hp}
	
	var formatted_string = string.format(attributes_dictionary)
	
	player.input_mode = player.INPUT_DIALOGUE
	dialogue_panel.dialogue_print(formatted_string)

func npc_event(player):
	npc_parse(dialogue_script, player)

func npc_parse(script, player):
	for instruction in script["stack"]:
		self.npc_call(instruction,player)
		
func npc_call(instruction, player):
	var exec = instruction.keys()[0]
	match exec:
		"if":
			if(Eval.eval(instruction["if"])):
				npc_call(instruction["then"],player)
			else:
				npc_call(instruction["else"],player)
		"print":
			npc_print(instruction["print"],player)
		"pre_print":
			pass # todo

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

	
