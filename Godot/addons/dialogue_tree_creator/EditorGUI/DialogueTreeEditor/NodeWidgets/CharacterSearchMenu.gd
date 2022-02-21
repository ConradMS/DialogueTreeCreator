extends Control

onready var popupMenu : PopupMenu = $PopupButton/PopupMenu
onready var recents = $PopupButton/PopupMenu/Recents
onready var button = $PopupButton
onready var charLabel = $CharLabel

const HEADER_DELIM = "#"
const CHARACTER_DELIM = ","

const NO_HEADER_YET = "null"
const ID = 0
const NAME = 1

const VALID_FILE_ENDING = ".txt"

const IMPORTS = "Imports"

var depth = 1
const default_path : String = "res://addons/dialogue_tree_creator/Databases/default_characters.txt"
var submenu_count = 1

func _ready():
	popupMenu.connect("index_pressed", self, "suggestions_menu_pressed", [popupMenu])
	recents.connect("index_pressed", self, "suggestions_menu_pressed", [recents])
	build_suggestions_tab(default_path)


func _on_PopupButton_pressed():
	popupMenu.popup()
	popupMenu.rect_position = get_global_mouse_position()
	# Simualte a ui_down event to automatically select the first option
	var ui_down = InputEventAction.new()
	ui_down.action = "ui_down"
	ui_down.pressed = true
	Input.parse_input_event(ui_down)
	
	# Simulate a ui_right event to automaticlally select first sub list
	var ui_right = InputEventAction.new()
	ui_right.action = "ui_right"
	ui_right.pressed = true
	Input.parse_input_event(ui_right)


func sync_recents(recents : PoolStringArray):
	popupMenu._build_recents(recents)


func suggestions_menu_pressed(index : int, menu : PopupMenu):
	var option : String = menu.get_item_text(index)
	charLabel.change_text_from_suggestions(option)


func is_correct_file_type(file_path : String) -> bool:
	if file_path.ends_with(VALID_FILE_ENDING):
		return true
	return false


func build_suggestions_tab(file_path : String):
	var file = File.new()

	if !file.file_exists(file_path):
		printerr("No such file to build suggestions tab: ", file_path)
		return

	file.open(file_path, file.READ)
	if file.eof_reached():
		printerr("empty file to build suggestions tab: ", file_path)
		return
	
	if !(is_correct_file_type(file_path)):
		printerr("File to build expressions tab must be a .txt file: ", file_path)
		return
	
	var exisiting_children = get_existing_children()
	submenu_count = count_submenus()
	var first_line = file.get_line().trim_prefix(" ")
	
	if first_line[0] != HEADER_DELIM:
		printerr("Character database must start with a header")
		return

	var current_submenu : PopupMenu = _make_characters_submenu(first_line.lstrip(HEADER_DELIM).dedent(), popupMenu)
	
	while !file.eof_reached(): 
		var next_line : String = file.get_line()
		next_line.trim_prefix(" ")
		
		if next_line.length() > 0:
			if next_line[0] == HEADER_DELIM:
				var parent_popup = _get_parent_popup(next_line, current_submenu)
				
				if parent_popup == null:
					revert_change(exisiting_children)
					return

				current_submenu = _make_characters_submenu(next_line.lstrip(HEADER_DELIM).dedent(), parent_popup)
			else:
				# Split into two sections, the first is id, second is name
				# For now dont do anything with id
				var char_info : PoolStringArray = next_line.split(CHARACTER_DELIM, true, 2)
				current_submenu.add_item(char_info[NAME])
				# Use this later probably:
	#			current_submenu.set_item_id()
	complete_changes(exisiting_children)

func complete_changes(exisiting_children: Array):
	for child in popupMenu.get_children():
		if child in exisiting_children:
			child.queue_free()
	
	for i in range(1, submenu_count):
		popupMenu.remove_item(1)
	depth = 1


func count_submenus():
	var count = 0
	for child in popupMenu.get_children():
		if child is PopupMenu:
			count += 1
	return count


func revert_change(existing_children: Array):
	for child in popupMenu.get_children():
		if !(child in existing_children or child == recents):
			child.queue_free()


func get_existing_children() -> Array:
	var existing = []
	for child in popupMenu.get_children():
		if child != recents and child is PopupMenu:
			existing.append(child)
	return existing 
	

# Return the Current menu
func _make_characters_submenu(menu_name : String, parentPopup : PopupMenu) -> PopupMenu:
	var new_submenu = PopupMenu.new()
	new_submenu.connect("index_pressed", self, "suggestions_menu_pressed", [new_submenu])
	parentPopup.add_child(new_submenu)
	parentPopup.add_submenu_item(menu_name, new_submenu.name)
	
	return new_submenu


func _get_parent_popup(next_line : String, child : PopupMenu) -> PopupMenu:
	var count = 0
	var index = 0
	while index < next_line.length() and next_line[index] == HEADER_DELIM:
		count += 1
		index += 1
		
	if count > depth:
		if count == depth + 1:
			depth += 1
			return child
		else:
			printerr("Formatting error in character database")
			return null
	else:
		var parent = child.get_parent()
		depth -= 1
		while depth > count - depth:
			if !(parent is PopupMenu):
				printerr("Parent menu is not popupmenu for some reason")
				return null
			depth -= 1
			parent = parent.get_parent()

		depth += 1
		return parent 


func add_name(new_name : String):
	if is_existing_name(new_name, popupMenu):
		return
	
	var has_import = false
	var imports_menu : PopupMenu
	for child in popupMenu.get_children():
		if child.name == IMPORTS:
			has_import = true
			imports_menu = child
			
	if !has_import:
		imports_menu = add_imports_menu()
	
	imports_menu.add_item(new_name)


func add_imports_menu() -> PopupMenu:
	var imports = PopupMenu.new()
	
	popupMenu.add_child(imports)
	imports.name = IMPORTS
	popupMenu.add_submenu_item(IMPORTS, IMPORTS)
	
	imports.connect("index_pressed", self, "suggestions_menu_pressed", [imports])
	return imports


func is_existing_name(target : String, popup : PopupMenu):
	var exists = false
	
	for i in range(0, popup.get_item_count()):
		if popup.get_item_text(i) == target:
			exists = true
	
	if !exists:
		for child in popup.get_children():
			if child is PopupMenu:
				exists = exists or is_existing_name(target, child)
	
	return exists
	
