extends Node2D

export (String) var tileset

# size of an character tile
var TILE_SIZE = Vector2(16.0,16.0)

onready var bounds_array = [] # array that contains all of the collision polygons. Populated on _ready

func _ready():
	NpcParser.initialize($MainCamera/UI/DialoguePanel)
	
	# loading tileset configuration
	var tileset_config = ConfigFile.new()
	var load_result = tileset_config.load("res://graphics/" + tileset + "/config.ini")
	if(load_result == OK):
		TILE_SIZE.x = tileset_config.get_value("size","size_vertical")
		TILE_SIZE.y = tileset_config.get_value("size","size_horizontal")
		$MainCamera.zoom_table = tileset_config.get_value("camera","zoom_table")
	elif(load_result == ERR_FILE_NOT_FOUND):
		print("connfig.ini of a(n) " + self.tileset + " not found.")
	else:
		print("Error when loading config.ini of a given tileset.")
