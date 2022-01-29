extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.gd"

onready var textbox = $ChoiceLinkText
var link_text : String = ""


func _on_ChoiceLinkText_text_changed():
	link_text = textbox.text


func get_var_dict() -> Dictionary:
	var var_dict = .get_var_dict()
	var_dict[DialogueTreeVariableNames.CHOICE_LINK_VARS.CHOICE_TEXT] = link_text
	return var_dict
