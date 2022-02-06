extends Control

const default_path = "res://addons/dialogue_tree_creator/Databases/default_conditions.txt"
const SECTION_DELIM = "#"
const SUBMENU_DELIM = "*"
const VALID_FILE_TYPE = ".txt"
onready var conditions_box_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/PopupConditionList.tscn")
onready var popup = $ConditionsSelector
onready var textureButton = $TextureButton

signal selection_made()

var condition_boxes : Dictionary = {}
var depth = 0

func _ready():
	build_conditions(default_path)

func is_correct_file_type(file_path : String):
	if file_path.ends_with(VALID_FILE_TYPE):
		return true
	return false


func build_conditions(file_path : String):
	var file = File.new()
	if !file.file_exists(file_path):
		printerr("File not found while trying to build conition list: ", file_path)
		return 
	
	if !(is_correct_file_type(file_path)):
		printerr("File type not valid, conditions list must be built from a .txt file, provided: ", file_path)
		return
	
	var current_id = popup.get_item_count() - 1
	file.open(file_path, file.READ)
	
	var current_header : PopupMenu = popup
	var submenu = false
	
	reset_submenu()
	while !file.eof_reached():
		var next_line = file.get_line()
		submenu = false
		
		if next_line.length() > 0:
			if next_line[0] == SECTION_DELIM or next_line[0] == SUBMENU_DELIM:
				
				if next_line[0] == SUBMENU_DELIM:
					submenu = true
					next_line = next_line.lstrip(SUBMENU_DELIM)
				
				update_header(next_line, current_header)
				next_line = next_line.lstrip(SECTION_DELIM).dedent()
				
				if submenu:
					var newPopupMenu = PopupMenu.new()
					
					newPopupMenu.connect("id_pressed", self, "_on_ConditionsSelector_id_pressed")
					
					current_header.add_child(newPopupMenu)
					current_header.add_submenu_item(next_line, newPopupMenu.name)
					current_header = newPopupMenu
				else:
					current_id += 1
					current_header.add_item(next_line, current_id)
					var new_conditions_box = conditions_box_scene.instance()
					self.add_child(new_conditions_box)
					
					var item_list = new_conditions_box.get_conditions_list()
					item_list.connect("multi_selected", self, "update_conditions")
					
					condition_boxes[current_id] = new_conditions_box
			elif condition_boxes.has(current_id):
				var condition_box : ConditionBox = condition_boxes[current_id]
				condition_box.add_new_condition(next_line)
			else:
				printerr("Incorrectly formatted .txt file to build conditions list")


func reset_submenu():
	for child in popup.get_children():
		if child is PopupMenu:
			child.queue_free()
	popup.clear()


func update_header(header : String, current_popup : PopupMenu):
	var header_depth = 0
	var index = 0
	while index < header.length() and header[index] == SECTION_DELIM:
		header_depth += 1
		index += 1
		
	if header_depth <= depth:
		for i in range(0, depth - header_depth):
			if current_popup.get_parent() is PopupMenu:
				current_popup = current_popup.get_parent()
			else:
				printerr("Parent of submenu is not popupMenu")
				
	depth = header_depth


func update_conditions(_index : int, _selected : bool):
	emit_signal("selection_made")


func get_selected() -> PoolStringArray:
	var selected : PoolStringArray = []
	for box in condition_boxes.values():
		if box is ConditionBox:
			var item_list = box.get_conditions_list()
			for item in item_list.get_selected_items():
				selected.append(item_list.get_item_text(item))
	
	return selected


func add_external_condition_box(box_name : String, box : ConditionBox):
	var new_id = condition_boxes.size()
	condition_boxes[condition_boxes.size()] = box
	var item_list = box.get_conditions_list()
	item_list.connect("multi_selected", self, "update_conditions")
	
	popup.add_item(box_name, new_id)


func _on_ConditionsSelector_id_pressed(id):
	if condition_boxes.has(id):
		var box : ConditionBox = condition_boxes[id]
		box.show_box()
	else:
		printerr("id of conidition boxes are not storing properly")


func _on_TextureButton_pressed():
	popup.popup()
	popup.rect_position = get_global_mouse_position()
	popup.rect_position.x += textureButton.rect_size.x * 1.5


func _on_ConditionSelectorRoot_resized():
	textureButton.rect_size.y = rect_size.y
