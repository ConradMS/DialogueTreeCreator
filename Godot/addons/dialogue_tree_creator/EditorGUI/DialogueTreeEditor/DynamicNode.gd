extends "res://DialogueGraphNode.gd"
onready var script_selector = $ScriptSelectorRoot

const DYNAM_NODE_TITLE = "Dynamic Node, id: "


func _ready():
	create_title(DYNAM_NODE_TITLE)
	type = DialogueTreeVariableNames.NODE_TYPES.DIALOGUE_NODE


func get_var_dict():
	var var_dict : Dictionary = .get_var_dict()
	var_dict[DialogueTreeVariableNames.DYANIMC_NODE_VARS.SCRIPTS] = script_selector.export_all_method_details()
	return var_dict

