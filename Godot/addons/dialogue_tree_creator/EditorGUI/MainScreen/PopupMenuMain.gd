extends PopupMenu

const INPUT_ACTION : String = "add_menu"

func _ready():
	_add_input_map()


func _add_input_map():
	if InputMap.has_action(INPUT_ACTION):
		return
	
	InputMap.add_action(INPUT_ACTION)
	var rightClick = InputEventMouseButton.new()
	rightClick.device = 0
	rightClick.button_index = BUTTON_RIGHT
	InputMap.action_add_event(INPUT_ACTION, rightClick)
	

func _process(delta):
	
	if Input.is_action_just_pressed(INPUT_ACTION):
		if Engine.editor_hint:
			popup()


func _on_PopupMenu_id_pressed(id):
	print("yay")
