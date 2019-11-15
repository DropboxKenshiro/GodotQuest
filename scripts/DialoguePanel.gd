extends Panel

enum {STATE_IDLE,STATE_TALK, STATE_CHOICE}
var dialogue_state

onready var choice_label = preload("res://prototypes/Choice.tscn")
onready var choice_container = $"ChoiceContainer"

onready var current_dialogue_array = []
var choice_index = null # equals null if choice isn't active

var current_npc_reference #reference do npc you're currently talking to.

signal dialogue_begin
signal choice_begin
signal dialogue_end
signal choice_end

func _ready():
	pass

func enable_dialogue():
	emit_signal("dialogue_begin")
	dialogue_state = STATE_TALK
	self.show()

func disable_dialogue():
	self.hide()
	$"Dialogue".bbcode_text = ""
	current_npc_reference = null
	current_dialogue_array.clear()
	NpcParser.wait_flag = false
	emit_signal("dialogue_end")

func dialogue_add(text: Array):
	var initialized = false
	
	if(current_dialogue_array.empty()):
		enable_dialogue()
		initialized = true
	for string in text:
		current_dialogue_array.append(string)
	if(initialized):
		feed_dialogue()

func feed_dialogue():
	# check if we're at the end of array
	# in other words, clearing after dialogue is done
	if(current_dialogue_array.empty()):
		disable_dialogue()
		return
	
	# this match instruction handles special codes
	# they begin with '!' and do something special
	match current_dialogue_array.front():
		"!CLR": # clears screen
			$"Dialogue".bbcode_text = ""
			current_dialogue_array.pop_front()
			if(!current_dialogue_array.empty()):
				continue
			else:
				disable_dialogue()
				return
		_: # no special code, add text to the textbox
			$"Dialogue".bbcode_text += current_dialogue_array.pop_front()

func enable_choices(possible):
	emit_signal("choice_begin")
	choice_index = 0
	dialogue_state = STATE_CHOICE
	
	choice_container.show()
	for choice in possible:
		var new_choice = choice_label.instance()
		new_choice.name = choice
		new_choice.text = choice
		choice_container.add_child(new_choice)
	
	# selecting first element as a default choice
	choice_container.get_child(0).set_choice(true)

func disable_choices() -> String:
	var chosen = choice_container.get_child(choice_index).name
	
	for choice in self.choice_container.get_children():
		choice.queue_free()
	
	emit_signal("choice_end")
	return chosen

func choice_change(direction):
	choice_container.get_child(self.choice_index).set_choice(false)
	self.choice_index = int(clamp(self.choice_index + direction,0,self.get_child_count() - 1))
	choice_container.get_child(self.choice_index).set_choice(true)
	
func _on_Hero_dialogue_trigger():
	match dialogue_state:
		STATE_TALK:
			feed_dialogue()
		STATE_CHOICE:
			disable_choices()

# notice, -1 means left, 1 means right
func _on_Hero_choice_change(direction):
	if(self.choice_index != null):
		choice_change(direction)