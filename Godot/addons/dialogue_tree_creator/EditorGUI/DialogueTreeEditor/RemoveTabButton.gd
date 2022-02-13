extends TextureButton
class_name MinusButton

var tab_id = -1
signal remove_tab(id)

func _on_RemoveTabButton_pressed():
	emit_signal("remove_tab", tab_id)
