extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.gd"

onready var textbox = $ChoiceLinkText
var link_text : String = ""


func _on_ChoiceLinkText_text_changed():
	link_text = textbox.text


func get_var_dict() -> Dictionary:
	var var_dict = .get_var_dict()
	var_dict[DialogueTreeVariableNames.CHOICE_LINK_VARS.CHOICE_TEXT] = link_text
	return var_dict


func build_from_var_dict(var_dict : Dictionary) -> bool:
	var ok = .build_from_var_dict(var_dict)
	
	var required_vars = DialogueTreeVariableNames.CHOICE_LINK_VARS.values()
	if(!var_dict.has_all(required_vars)):
		printerr("Choice link does not have all of the required variables")
		ok = false
		return ok
	
	var link_text_var = var_dict[DialogueTreeVariableNames.CHOICE_LINK_VARS.CHOICE_TEXT]
	if (!link_text_var is String):
		printerr("Choice link varaibles are not saved as the proper type")
		ok = false
	
	link_text = link_text_var
	return ok
