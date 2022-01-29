extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/NodeParamRoot.gd"

const x_hint = "X: "
const y_hint = "Y: "
onready var x_label = $NodeParamRoot/HBoxContainer/X
onready var y_label = $NodeParamRoot/HBoxContainer/Y

const allowed_chars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "-"]

func _ready():
	value = Vector2(0, 0)

func _on_X_text_changed(new_text : String):
	if new_text.length() < 3:
		x_label.text = x_hint
	else:
		if new_text[new_text.length() - 1] in allowed_chars:
			value.x = int(new_text.substr(x_hint.length() + 1))
			string_value = str(value.x) + ", " + str(value.y)
		else:
			x_label.text = new_text.substr(0, new_text.length() - 1)


func _on_Y_text_changed(new_text):
	if new_text.length() < 3:
		y_label.text = y_hint
	else:
		if new_text[new_text.length() - 1] in allowed_chars:
			value.y = int(new_text.substr(y_hint.length() + 1))
			string_value = str(value.x) + ", " + str(value.y)
		else:
			y_label.text = new_text.substr(0, new_text.length() - 1)
