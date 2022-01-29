extends Control
class_name NodeScriptParam

var value
var string_value : String
const info_node_name : String = "Info"
const hbox_name : String = "ComponentContainer"
var hbox : HBoxContainer

const types_to_name = {
	TYPE_INT: "int",
	TYPE_BOOL: "boolean",
	TYPE_REAL: "float",
	TYPE_ARRAY: "array",
	TYPE_COLOR: "colour",
	TYPE_STRING: "string",
	TYPE_VECTOR2: "vector2",
	"unkown": "var"
}

func _ready():
	hbox = find_child(self, hbox_name)
	rect_min_size = get_minimum_size()

## This is incase the nodepath changes forwhatever reason in the child instances
func find_child(target : Node, node_name : String) -> Node:
	var res = null
	for child in target.get_children():
		if child.name == node_name:
			res = child
		else:
			var child_res = find_child(child, node_name)
			if child_res != null:
				res = child_res
	return res
	
	
func set_info(var_name : String, var_type : int):
	var info : Label = find_child(self, info_node_name)
	if(info):
		info.text = "Param name: %s    Param Type: %s" % [var_name, types_to_name[var_type]]


func get_minimum_size():
	if hbox.has_method("get_adj_min_size"):
		return hbox.get_adj_min_size()
	else:
		printerr("Finding wrong hbox in nodescript param")
		return Vector2(0, 0)
