extends "res://DialogueGraphNode.gd"
onready var script_selector = $ScriptSelectorRoot
class_name DynamicNode

const DYNAM_NODE_TITLE = "Dynamic Node, id: "


func _ready():
	create_title(DYNAM_NODE_TITLE)
	type = DialogueTreeVariableNames.NODE_TYPES.DIALOGUE_NODE


func get_var_dict():
	var var_dict : Dictionary = .get_var_dict()
	var_dict[DialogueTreeVariableNames.DYANIMC_NODE_VARS.SCRIPTS] = script_selector.export_all_method_details()
	return var_dict


func sync_graph_node():
	.sync_graph_node()


func build_from_var_dict(var_dict : Dictionary) -> bool:
	var ok = .build_from_var_dict(var_dict)
	var required_vars : Array = DialogueTreeVariableNames.DYANIMC_NODE_VARS.values()
	
	if(!var_dict.has_all(required_vars)):
		printerr("Dynamic node does not contain all of the required variables")
		ok = false
		return ok
	
	var scripts = var_dict[DialogueTreeVariableNames.DYANIMC_NODE_VARS.SCRIPTS]
	
	var node_theme = var_dict[DialogueTreeVariableNames.DYANIMC_NODE_VARS.THEME]
	
	# For now do nothing with theme because Im not sure how they're going to be implemented
	
	return ok
