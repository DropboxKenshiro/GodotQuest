extends Panel

var current_dialogue_array = PoolStringArray()
var dialogue_index = 0

signal dialogue_end

func _ready():
	pass

# few notes on dialogue splitting
# | and || are reserved for splitting purposes
# | stops dialogue and resumes after dialogue_forward
# || stops dialogue, but after dialogue_forward it clears screen
func dialogue_print(text):
	self.show()
	
	current_dialogue_array = text.split('|') # note, || will give additional, empty string. It's useful for detecting screen clear.
	self.dialogue_index = 0
	$"Dialogue".bbcode_text = current_dialogue_array[dialogue_index]

func feed_dialogue():
	dialogue_index += 1
	if(dialogue_index == current_dialogue_array.size()):
		self.hide()
		$"Dialogue".bbcode_text = ""
		emit_signal("dialogue_end")
		return
	if(current_dialogue_array[dialogue_index] == ''):
		$"Dialogue".bbcode_text = ""
		dialogue_index += 1
	$"Dialogue".bbcode_text += current_dialogue_array[dialogue_index]

func _on_Hero_dialogue_forward():
	feed_dialogue()
