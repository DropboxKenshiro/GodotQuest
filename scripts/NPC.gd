extends StaticBody2D

class_name NPC

# enum determining type of activation
enum ActivationType {ACTIVATE_WALK_INTO, ACTIVATE_TRIGGER}
# enum defining internal return types of parser
enum {RETURN_NORMAL, RETURN_INPUT_WAIT = 10}

var event_trigger # reference to collider that represents trigger area. If null, it's the default collider

var input_wait_flag # flag that marks waiting for input during script parsing

onready var dialogue_panel = $"../MainCamera/UI/DialoguePanel"

var dialogue_script

export (String) var given_name # given name of an NPC. Could be blank
export (String) var occupation # occupation, like a Shopkeeper
export (String) var title # honorary title of an NPC
export (String) var npc_id # id that is used for searches etc.

export (ActivationType) var activation_type # determines how event is activated

func choice_print(choices):
	dialogue_panel.enable_choices(PoolStringArray(choices))

func npc_event(player):
	NpcParser.parse(self, player)

func _ready():
	pass

	
