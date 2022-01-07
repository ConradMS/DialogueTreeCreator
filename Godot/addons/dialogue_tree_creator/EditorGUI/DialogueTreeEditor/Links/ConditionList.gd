extends ItemList

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		if has_focus():
			visible = false


func _add_condition(condition : String):
	call_deferred("grab_focus")
	for i in range(0, get_item_count()):
		if get_item_text(i) == condition:
			select(i, false)
			return
	
	add_item(condition)
	select(get_item_count() - 1, false)
	
