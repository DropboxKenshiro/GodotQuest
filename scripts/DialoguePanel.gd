extends Panel

enum {STATE_IDLE,STATE_TALK, STATE_CHOICE}
var dialogue_state

onready var choice_label = preload("res://prototypes/Choice.tscn")
onready var choice_container = $"ChoiceContainer"

onready var current_dialogue_array = []
var dialogue_index = STATE_IDLE
var choice_index = null # equals null if choice isn't active

var current_npc_reference #reference do npc you're currently talking to.

signal dialogue_end
signal choice_done

func _ready():
	pass

func dialogue_print(text):
	dialogue_state = STATE_TALK
	self.show()
	
	current_dialogue_array = text
	
	self.dialogue_index = 0
	$"Dialogue".bbcode_text = current_dialogue_array[0]

func feed_dialogue():
	dialogue_index += 1
	
	# check if we're at the end of array
	# in other words, clearing after dialogue is done
	if(dialogue_index == current_dialogue_array.size()):
		self.hide()
		$"Dialogue".bbcode_text = ""
		current_npc_reference = null
		NpcParser.wait_flag = false # since NpcParser is a singleton, signals not needed here
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

func enable_choices(possible):
	choice_index = 0
	
	choice_container.show()
	for choice in possible:
		var new_choice = choice_label.instance()
		new_choice.name = choice
		new_choice.text = choice
		choice_container.add_child(new_choice)
	
	# selecting first element as a default choice
	choice_container.get_child(0).set_choice(true)

func choice_change(direction):
	choice_container.get_child(self.choice_index).set_choice(false)
	self.choice_index = int(clamp(self.choice_index + direction,0,self.get_child_count() - 1))
	choice_container.get_child(self.choice_index).set_choice(true)
	
func _on_Hero_dialogue_trigger():
	match dialogue_state:
		STATE_TALK:
			feed_dialogue()
		STATE_CHOICE:
			pass #tbd

# notice, -1 means left, 1 means right
func _on_Hero_choice_change(direction):
	if(self.choice_index != null):
		choice_change(direction)