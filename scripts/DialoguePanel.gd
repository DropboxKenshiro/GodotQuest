extends Panel

onready var choice_label = preload("res://prototypes/Choice.tscn")
onready var choice_container = $"ChoiceContainer"

onready var current_dialogue_array = PoolStringArray()
var dialogue_index = 0

signal dialogue_end

func _ready():
	pass

func dialogue_print(text):
	self.show()
	
	# valid typer for dialogue are
	# array: by default interpretation of JSON
	# poolstringarray: given by npc_print()
	# string: in case of a singular string to print
	if(typeof(text) == TYPE_ARRAY):
		current_dialogue_array = PoolStringArray(text)
	elif(typeof(text) == TYPE_STRING):
		current_dialogue_array.append(text)
	elif(typeof(text) == TYPE_STRING_ARRAY):
		current_dialogue_array = text
	else:
		return ERR_INVALID_PARAMETER
	
	self.dialogue_index = 0
	$"Dialogue".bbcode_text = current_dialogue_array[dialogue_index]

func feed_dialogue():
	dialogue_index += 1
	
	# check if we're at the end of array
	if(dialogue_index == current_dialogue_array.size()):
		self.hide()
		$"Dialogue".bbcode_text = ""
		emit_signal("dialogue_end")
		return
	
	# this match instruction handles special codes
	# they begin with '!' and do something special
	match current_dialogue_array[dialogue_index]:
		"!CLR": # clears screen
			$"Dialogue".bbcode_text = ""
			feed_dialogue()
			return
			
	$"Dialogue".bbcode_text += current_dialogue_array[dialogue_index]

func enable_choices(possible: PoolStringArray):
	choice_container.show()
	for choice in possible:
		var new_choice = choice_label.instance()
		new_choice.name = choice
		new_choice.text = choice
		choice_container.add_child(new_choice)

func _on_Hero_dialogue_forward():
	feed_dialogue()
