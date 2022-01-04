tool
extends Sprite


func _process(delta):
	rotation_degrees += 1
	
	if Input.is_action_just_pressed("ui_accept"):
		print("true")
