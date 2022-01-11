extends CenterContainer

onready var messageLabel = $Message
const SPEED = 1.5
const MESSAGE_LENGTH = 1.0
const FPS = 60.0

func _process(_delta):
	if visible:
		rect_position.y -= SPEED
		modulate.a -= 1 / (FPS * MESSAGE_LENGTH)
		
		if modulate.a < 0:
			visible = false

func create_message_popup(message : String, pos : Vector2):
	modulate.a = 1
	messageLabel.text = message
	rect_position = pos
	visible = true
