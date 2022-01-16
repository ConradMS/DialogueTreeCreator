extends GraphNode
class_name TreeNode

var id : int = -1
var links : Dictionary = {}

signal remove_node(id)

func init(id_i : int):
	id = id_i
	self.connect("close_request", self, "delete_self")


func delete_self():
	emit_signal("remove_node", id)
	

func _input(event):
	if Input.is_key_pressed(KEY_BACKSPACE):
		if selected and !editing_children():
			delete_self()


func editing_children() -> bool:
	var editing = false
	for child in get_children():
		if child is Control:
			if child.has_focus():
				editing = true
	return editing 


func get_var_dict():
	var vars : Dictionary = {}
	vars[DialogueTreeVariableNames.TREE_NODE_VARS.ID] = id
	vars[DialogueTreeVariableNames.TREE_NODE_VARS.LINKS] = {}
	for link_i in links.values():
		if link_i is Link:
			var key = link_i.id
			vars[DialogueTreeVariableNames.TREE_NODE_VARS.LINKS][key] = link_i.get_var_dict()
		else:
			printerr("Object not of type Link in links")

	return vars
	

func toJSON() -> String:
	return to_json(get_var_dict())
