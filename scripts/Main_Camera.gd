extends Camera2D

onready var ui = $"UI"

export (Array) var zoom_table
var index = 0

func update_cam(new_position := self.position):
	if(new_position != self.position):
		self.position = new_position
	ui.rect_scale = self.zoom
	self.force_update_scroll()

func _input(event):
	if(event.is_action_pressed("Zoom In") and index < zoom_table.size() - 1):
		index += 1
		self.zoom = Vector2(self.zoom_table[index],self.zoom_table[index])
		update_cam()
	elif(event.is_action_pressed("Zoom Out") and index > 0):
		index -= 1
		self.zoom = Vector2(self.zoom_table[index],self.zoom_table[index])
		update_cam()

func _on_Hero_hero_moved(new_pos,nil):
	update_cam(new_pos)

func _ready():
	self.index = self.zoom_table.find(1.0)
