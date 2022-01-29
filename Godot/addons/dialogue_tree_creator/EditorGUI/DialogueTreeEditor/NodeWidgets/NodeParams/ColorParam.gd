extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/NodeParamRoot.gd"

onready var colorpickerButton = $NodeParamRoot/ComponentContainer/ColorPickerButton

const base_16 = {
	10: "a",
	11: "b",
	12: "c",
	13: "d",
	14: "e",
	15: "f"
}

func _on_ColorPickerButton_color_changed(color : Color):
	value = color
	string_value = to_argb(color)


func to_argb(color : Color) -> String:
	return to_hex(int(color.a * 255)) + to_hex(int(color.r * 255)) \
	+ to_hex(int(color.g * 255)) + to_hex(int(color.b * 255))
	
	
func to_hex(base_10 : int) -> String:
	var power = 0
	var string = ""
	while pow(16, power + 1) <= base_10:
		power += 1
	
	var remainder = base_10
	while power >= 0:
		var res = remainder / int(pow(16, power))
		remainder = remainder % int(pow(16, power))
		if res in base_16:
			string += base_16[res]
		else:
			string += str(res)
		
		power -= 1
	
	if string.length() == 1:
		string = "0" + string
	return string
