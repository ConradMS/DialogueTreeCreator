extends WindowDialog

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		popup()
		print("run")

