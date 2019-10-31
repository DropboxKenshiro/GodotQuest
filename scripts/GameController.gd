extends Node2D

# size of an character tile
var TILE_SIZE = Vector2(8.0,16.0)

onready var bounds_array = [] # array that contains all of the collision polygons. Populated on _ready

func _ready():
	NpcParser.initialize($MainCamera/UI/DialoguePanel)
