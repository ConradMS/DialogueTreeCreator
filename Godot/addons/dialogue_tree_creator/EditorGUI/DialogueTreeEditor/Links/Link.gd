extends Control


var linked_id : int
var priority : int
var conditions : PoolStringArray

signal remove_link()

func _on_RemoveLink_pressed():
	emit_signal("remove_link")
