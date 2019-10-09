extends "res://NPC.gd"

func _ready():
	npc_id = "foobar"

func npc_event(player):
	npc_print(player,"You have {player_hp} HP. That's good.")