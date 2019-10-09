extends Node

func eval(code_string):
	var to_eval = GDScript.new()
	to_eval.source_code = "func eval():\n\treturn " + code_string
	to_eval.reload()
	
	var eval_obj = Reference.new()
	eval_obj.set_script(to_eval)
	
	return eval_obj.eval()

func _ready():
	pass
