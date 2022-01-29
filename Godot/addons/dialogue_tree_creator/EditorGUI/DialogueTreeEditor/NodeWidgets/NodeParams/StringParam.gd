extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/NodeParamRoot.gd"

func _on_LineEdit_text_changed(new_text):
	value = new_text
	string_value = value
