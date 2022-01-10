extends GraphNode
class_name TreeNode

var id : int

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
