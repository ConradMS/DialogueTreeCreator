extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/NodeParamRoot.gd"

func _on_SpinBox_value_changed(value_i):
	value = value_i
	string_value = str(value)
