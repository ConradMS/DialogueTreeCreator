extends Control
class_name DialogueTreeControl

onready var addNodeMenu = $VSplitContainer/OptionsBar/HBoxContainer/AddnodeMenu
onready var dialogueTree : DialogueTree = $VSplitContainer/DialogueTree
onready var warningBox = $WarningMessage 

onready var fileMenu = $VSplitContainer/OptionsBar/HBoxContainer/FileMenu
var mouseMenu : PopupMenu
const FILE_MENU_EXTENSION = "_file_"

const CENTER_SCREEN = Vector2(640, 320)
# Called when the node enters the scene tree for the first time.
func _ready():
	var addNodePopup : PopupMenu = addNodeMenu.get_popup()
	mouseMenu = _copy_popup(addNodePopup)
	addNodePopup.connect("index_pressed", self, "_add_node")
	mouseMenu.connect("index_pressed", self, "_add_node", [true])
	
	dialogueTree.connect("warn", self, "add_warning")
	
	configure_file_menu()


func _copy_popup(popup : PopupMenu) -> PopupMenu:
	var newPopup = PopupMenu.new() 
	self.add_child(newPopup)
	newPopup.items = popup.items
	return newPopup
	

func _add_node(type : int, use_mouse_position : bool = false):
	var added_id : int = dialogueTree.add_node(type)
	var added_node : TreeNode = dialogueTree.nodes[added_id]
	if use_mouse_position:
		added_node.offset = (get_global_mouse_position() + dialogueTree.scroll_offset) / dialogueTree.zoom
		added_node.offset.y -= added_node.rect_size.y / 2
		

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed == true:
			if !(mouseMenu == null):
				mouseMenu.popup()
				mouseMenu.rect_position = get_global_mouse_position() 


func add_warning(warning : String):
	warningBox.create_message_popup(warning, Vector2(640, 320))
	

func configure_file_menu():
	var popup = fileMenu.get_popup()
	popup.connect("index_pressed", self, "handle_file_menu_action")
	
	
func handle_file_menu_action(action_index : int):
	var file_popup : PopupMenu = fileMenu.get_popup()
	var action = file_popup.get_item_text(action_index)
	var method = FILE_MENU_EXTENSION + action
	
	if has_method(method):
		call(method)
	else:
		printerr("No method found from file menu: ", method)


func _file_save():
	dialogueTree.export_dialogue_tree()
