extends Node2D

# classes that are utilities, they never be nodes, so they are loaded there to acess
#onready var Segment = preload("Segment.gd")

onready var controller = $".."
onready var ray = $"Ray"
onready var collider = $"Collider"
onready var camera = $"../MainCamera"
onready var focus = $"CameraFocus"

var bit_order = [1,0] # order in which bytes in mask are applied by default. Could be used for defining priority.

signal hero_moved
signal dialogue_trigger
signal choice_change

var internal_position = Vector2(0,0) setget set_internal_position, get_internal_position # position in game world's scale. Converted to real size automatically
var position_changed = false # dirty flag to optimize position changing

enum {INPUT_MOVE, INPUT_DIALOGUE, INPUT_CHOICE}
var input_mode = self.INPUT_MOVE

# hero statistics section
enum CharacterClass {WARRIOR, MAGE}
export (String) var hero_name
export (CharacterClass) var hero_class
var max_hp = 100
var hp = 100
var level = 1

func set_internal_position(new_value):
	internal_position = new_value

func get_internal_position():
	return internal_position

func _handle_input():
	match self.input_mode:
		INPUT_MOVE:
			var step_v = Vector2(0,0)
			if(Input.is_action_just_pressed("Trigger")):
				self.check_collision(Vector2.UP,1,[1])
			elif(Input.is_action_just_pressed("Up")):
				step_v.y = -1
			elif(Input.is_action_just_pressed("Down")):
				step_v.y = 1
			elif(Input.is_action_just_pressed("Left")):
				step_v.x = -1
			elif(Input.is_action_just_pressed("Right")):
				step_v.x = 1
			#if step_v is 0,0 then we didn't press anything to move
			if(step_v != Vector2(0,0)):
				if(step(step_v)):
					self.position_changed = true
		INPUT_CHOICE:
			if(Input.is_action_just_pressed("Left")):
				emit_signal("choice_change",-1)
			elif(Input.is_action_just_pressed("Right")):
				emit_signal("choice_change",1)
		INPUT_DIALOGUE, INPUT_CHOICE:
			if(Input.is_action_just_pressed("Trigger")):
				emit_signal("dialogue_trigger")

func check_collision(step_vector, activate_type, bit_table := bit_order):
	for bit in bit_table:
		self.ray.set_collision_mask_bit(bit, true)
		
		ray.cast_to = internal_to_world(step_vector)
		ray.force_raycast_update()
		if(ray.is_colliding()):
			var colliding_object = ray.get_collider()
			if(colliding_object.is_in_group("NPC") and colliding_object.activation_type == activate_type):
				colliding_object.npc_event(self)
				return true
			else:
				return true
		
		self.ray.set_collision_mask_bit(bit, false)
	return false

func step(move_vector):
	var after_move = self.internal_position + move_vector
	if(!check_collision(move_vector,0)):
		self.internal_position = after_move
		return true
	else:
		return false

func internal_to_world(vector):
	var to_return = Vector2()
	to_return.x = vector.x * controller.TILE_SIZE.x
	to_return.y = vector.y * controller.TILE_SIZE.y
	return to_return

func world_to_internal(vector):
	var to_return = Vector2()
	to_return.x = vector.x / controller.TILE_SIZE.x
	to_return.y = vector.y / controller.TILE_SIZE.y
	return to_return

func trigger_event():
	pass

func _ready():
	# calculate internal position at start
	self.internal_position = world_to_internal(self.position)
	
	# add collider so it won't affect ray
	ray.add_exception(collider)

func _process(delta):
	self.position_changed = false

	_handle_input()

	if(self.position_changed):
		self.position = internal_to_world(internal_position)
		emit_signal("hero_moved",focus.global_position)

func _on_DialoguePanel_dialogue_end():
	self.input_mode = INPUT_MOVE

func _on_DialoguePanel_dialogue_begin():
	self.input_mode = INPUT_DIALOGUE

func _on_DialoguePanel_choice_begin():
	self.input_mode = INPUT_CHOICE

func _on_DialoguePanel_choice_end():
	self.input_mode = INPUT_MOVE
