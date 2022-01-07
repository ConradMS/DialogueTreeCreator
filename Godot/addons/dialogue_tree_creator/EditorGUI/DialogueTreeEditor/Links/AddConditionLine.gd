extends LineEdit

signal add_condition(condition)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		if has_focus():
			emit_signal("add_condition", text)
			visible = false


func _on_AddConditionLine_visibility_changed():
	if visible:
		text = ""
