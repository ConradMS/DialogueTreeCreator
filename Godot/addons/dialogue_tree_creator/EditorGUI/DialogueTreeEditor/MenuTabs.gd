extends HBoxContainer

onready var curr_open : MenuButton = null

func switch_option(pos : Vector2):
	var menu_option = find_option(pos)
	
	if menu_option == null or !(menu_option is MenuButton):
		return 
	
	if curr_open != null and curr_open is MenuButton:
		curr_open.get_popup().visible = false
		
	curr_open = menu_option
	popup_in_position(menu_option)

func find_option(pos : Vector2) -> MenuButton:
	for child in get_children():
		if child is MenuButton:
			if is_in_bounds(child, pos):
				return child
	return null


func popup_in_position(menu : MenuButton):
	menu.get_popup().popup()
	menu.get_popup().rect_position.x = menu.rect_position.x
	menu.get_popup().rect_position.y = menu.rect_position.y + menu.rect_size.y


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			switch_option(event.position)

	if curr_open == null or curr_open.get_popup().visible == false:
		return

	if event is InputEventMouseMotion:
		check_autoclose(event.position)
		check_autoopen(event.position)


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
	if pos.y > get_maxpopup_bounds(curr_open.get_popup()).y + 50:
		curr_open.get_popup().visible = false


func check_autoopen(pos : Vector2):
	var menu_option = find_option(pos)
	
	if menu_option == null or !(menu_option is MenuButton):
		return
	
	if menu_option != curr_open:
		curr_open.get_popup().visible = false
		curr_open = menu_option
		popup_in_position(curr_open)


func is_in_bounds(target : Control, pos : Vector2) -> bool:
	var min_pos = target.rect_position
	var max_pos = min_pos + target.rect_size
	return  (min_pos.x < pos.x and pos.x < max_pos.x) and (min_pos.y < pos.y and pos.y < max_pos.y)
