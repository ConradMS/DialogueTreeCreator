extends TextEdit

signal add_recent(recent)

func _input(event):
	# Stop editing text field if currently editing text field and you press enter
	if has_focus():
		if Input.is_key_pressed(KEY_ENTER):
			emit_signal("add_recent", text)
			release_focus()
