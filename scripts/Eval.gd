extends Node

func make_path(var_name, object):
	var tree_path = String(object.get_path())
	#tree_path.erase(0,1) # trim the first slash
	return ("\tvar " + var_name + "=get_node(\"" + tree_path + "\")\n") # e.g. "var Hero = /GameController/Hero"

func eval(code_string, npc_reference = null, player_reference = null, references := []):
	var to_eval = GDScript.new()
	to_eval.source_code += "extends Node\nfunc eval():\n"
	
	if(npc_reference != null):
		to_eval.source_code += make_path("NPC", npc_reference)
	if(player_reference != null):
		to_eval.source_code += make_path("Player", player_reference)
	
	if(!references.empty()):
		for node in references:
			to_eval.source_code += make_path(node.name, node)
	
	to_eval.source_code += "\treturn " + code_string
	var check = to_eval.source_code
	print(check)
	to_eval.reload()
	
	var eval_obj = Node.new()
	self.add_child(eval_obj, true)
	$Node.set_script(to_eval)
	print_tree_pretty()
	
	var value = eval_obj.eval()
	
	self.remove_child(eval_obj)
	eval_obj.queue_free()
	
	return value

func exec(code_string, npc_reference = null, player_reference = null, references := []):
	var to_eval = GDScript.new()
	to_eval.source_code += "extends Node\nfunc exec():\n"
	
	if(npc_reference != null):
		to_eval.source_code += make_path("NPC", npc_reference)
	if(player_reference != null):
		to_eval.source_code += make_path("Player", player_reference)
	
	if(!references.empty()):
		for node in references:
			to_eval.source_code += make_path(node.name, node)
	
	to_eval.source_code += "\t" + code_string
	var check = to_eval.source_code
	print(check)
	to_eval.reload()
	
	var eval_obj = Node.new()
	self.add_child(eval_obj, true)
	$Node.set_script(to_eval)
	print_tree_pretty()
	
	var value = eval_obj.exec()
	
	self.remove_child(eval_obj)
	eval_obj.queue_free()
	
	return value

func _ready():
	pass
