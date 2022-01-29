extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/NodeParamRoot.gd"

onready var checkbox = $NodeParamRoot/ComponentContainer/CheckBox

func _on_CheckBox_pressed():
	value = checkbox.pressed
	if(value):
		string_value = "true"
	else:
		string_value = ""
