extends Label

# styleboxes for label's background
export (StyleBox) var state_chosen
export (StyleBox) var state_not_chosen
# corresponding colors
export (Color) var state_chosen_color
export (Color) var state_not_chosen_color

var is_chosen = false

func set_choice(state: bool):
	self.is_chosen = state
	
	if(is_chosen):
		self.add_stylebox_override("normal", state_chosen)
		self.add_color_override("font_color", state_chosen_color)
	else:
		self.add_stylebox_override("normal", state_not_chosen)
		self.add_color_override("font_color", state_not_chosen_color)

func toggle_choice():
	self.set_choice(!self.is_chosen)