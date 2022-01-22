extends MenuButton

onready var min_position = rect_position
onready var max_position = min_position + rect_size
onready var min_popup_pos = Vector2(min_position.x, max_position.y)
onready var max_popup_pos = min_popup_pos + get_popup().rect_size

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			check_open(event.position)
			
	if get_popup().visible == false:
		return
	
	if event is InputEventMouseMotion:
		check_autoclose(event.position)

func get_maxpopup_bounds(popup : PopupMenu) -> Vector2:
	var max_size = popup.rect_size
	var max_child_size : Vector2
	for child in popup.get_children():
		if child is PopupMenu:
			max_child_size = get_maxpopup_bounds(child)
			if max_child_size.y > max_size.y:
				max_size.y = max_child_size.y
	
	return max_size


func check_autoclose(pos : Vector2):
	if pos.y > get_maxpopup_bounds(get_popup()).y + 50:
		get_popup().visible = false


func check_open(pos : Vector2):
	if(!is_in_bounds(min_popup_pos, max_popup_pos, pos)):
		if get_popup().visible:
			get_popup().call_deferred("set", "visible", false)

	if (is_in_bounds(min_position, max_position, pos)):
		get_popup().popup()
		get_popup().rect_position = min_popup_pos


func is_in_bounds(min_pos : Vector2, max_pos : Vector2, pos : Vector2) -> bool:
	return  (min_pos.x < pos.x and pos.x < max_pos.x) and (min_pos.y < pos.y and pos.y < max_pos.y)
