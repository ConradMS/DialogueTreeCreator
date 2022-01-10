extends Control

onready var popupMenu = $PopupButton/PopupMenu
onready var button = $PopupButton
onready var charLabel = $CharLabel


func _ready():
	pass
#	var status = charLabel.connect("add_recent", popupMenu, "add_recent")
#	if status != OK:
#		printerr("CharacterSearchMenu.gd, Line 13, Error: ", status)


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
