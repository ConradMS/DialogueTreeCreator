extends Control

const UNAMED = "Dialogue Tree"
const TAB_MARGIN = 15
const SCREEN_WIDTH = 1024

onready var remove_tab_button_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/RemoveTabButton.tscn")
onready var dialogue_tree_control_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/DialogueTreeControl.tscn")

onready var add_tab_button = $AddTabButton
onready var tabContainer : TabContainer = $VBoxContainer/TabContainer

var minus_buttons : Array = []


func _ready():
	_adjust_tab_width()


func _adjust_tab_width():
	var style_box_fg = tabContainer.get_stylebox("tab_fg")
	var style_box_bg = tabContainer.get_stylebox("tab_bg")
	
	var remove_tab_button = remove_tab_button_scene.instance()
	var texture : Texture = remove_tab_button.texture_normal
	var texture_width = texture.get_size().x
	
	style_box_fg.content_margin_right += texture_width
	style_box_bg.content_margin_right += texture_width


func _on_AddTabButton_pressed():
	_add_tab()


func _add_tab():
	var new_dialogue_tree = dialogue_tree_control_scene.instance()
	
	new_dialogue_tree.connect("tree_exited", self, "readjust_remove_buttons")
	new_dialogue_tree.connect("tree_exited", self, "_move_add_button")
	
	new_dialogue_tree.name = get_new_name()
	tabContainer.add_child(new_dialogue_tree)
	_add_new_minus_button()
	_move_add_button()


func _add_new_minus_button():
	var minus_button = remove_tab_button_scene.instance()
	minus_button.tab_id = tabContainer.get_tab_count() - 1
	
	minus_button.connect("remove_tab", self, "remove_tab")

	self.add_child(minus_button)
	
	minus_buttons.append(minus_button)
	
	var texture_size = minus_button.texture_normal.get_size().x
	minus_button.rect_position.x = get_total_tab_width() - texture_size


func remove_tab(tab_id : int):
	var dialogue_tree = tabContainer.get_tab_control(tab_id)
	
	if dialogue_tree is DialogueTreeControl:
		# Here see if the tree is unsaved:
		
		dialogue_tree.queue_free()
		var index = get_minus_button_by_id(tab_id)
		minus_buttons[index].queue_free()
		minus_buttons.remove(index)
	else:
		printerr("Tab is not a dialogue tree control")
	
	for minus_button in minus_buttons:
		if minus_button is MinusButton:
			if minus_button.tab_id > tab_id:
				minus_button.tab_id -= 1


func get_minus_button_by_id(id : int) -> int:
	for i in range(0, minus_buttons.size()):
		if minus_buttons[i] is MinusButton:
			if minus_buttons[i].tab_id == id:
				return i
	
	printerr("No minus button with id ", id)
	return -1


func readjust_remove_buttons():
	if minus_buttons.size() < 1:
		return
	
	var minus_button = remove_tab_button_scene.instance()
	
	var style_box : StyleBox = tabContainer.get_stylebox("tab_fg")
	var total_width = -minus_button.texture_normal.get_size().x
	
	for i in range(0, tabContainer.get_tab_count()):
		var width = 0
		var font : Font = tabContainer.get_font("font")
		var box_text = tabContainer.get_tab_title(i)
		
		var text_width = font.get_string_size(box_text)
		width += text_width.x
		width += style_box.content_margin_left + style_box.content_margin_right
		total_width += width
		
		var button_index = get_minus_button_by_id(i)
		var button = minus_buttons[button_index]

		if button is Control:
			button.rect_position.x = total_width


func get_new_name() -> String:
	var number = 0
	var new_tree_name = UNAMED
	while any_named(new_tree_name):
		number += 1
		new_tree_name = UNAMED + " " + str(number)
	return new_tree_name
	

func any_named(target_name : String):
	for child in tabContainer.get_children():
		if child.name == target_name:
			return true
	return false


func _move_add_button():
	var tab_width = get_total_tab_width()
	
	if tab_width < SCREEN_WIDTH:
		add_tab_button.rect_position.x = tab_width + TAB_MARGIN


func get_total_tab_width() -> int:
	var style_box : StyleBox = tabContainer.get_stylebox("tab_fg")
	var total_width = 0
	
	for i in range(0, tabContainer.get_tab_count()):
		var font : Font = tabContainer.get_font("font")
		var box_text = tabContainer.get_tab_title(i)

		var text_width = font.get_string_size(box_text)
		total_width += text_width.x
		total_width += style_box.content_margin_left + style_box.content_margin_right
	
	return total_width 
