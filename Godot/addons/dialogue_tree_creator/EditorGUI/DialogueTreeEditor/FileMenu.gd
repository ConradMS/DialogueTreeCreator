extends MenuButton

const NO_LOCATION_SET = "NOLOCATIONSET"
const FILE_ACTION_EXTENSION = "_file_"
var save_location : String = NO_LOCATION_SET
const INDEX = {SAVE = 1, SAVE_AS = 2}
const default_open_path = "res://addons/dialogue_tree_creator/Databases/"

onready var file_dialogue = $SettingsFileDialogue
onready var open_dialogue = $OpenFileDialogue
signal save(path)
signal open(path)

func _ready():
	setup_file_menu()

func setup_file_menu():
	var popup = get_popup()
	popup.connect("index_pressed", self, "_handle_file_action")
	
	file_dialogue.add_filter("*.JSON ; Json")
	open_dialogue.add_filter("*.JSON ; Json")
	
	var test_dir = Directory.new()
	if test_dir.dir_exists(default_open_path):
		open_dialogue.current_dir = default_open_path
	


func _handle_file_action(action_index : int):
	var popup = get_popup()
	var action_text : String = popup.get_item_text(action_index)
	action_text = action_text.replace(" ", "_")
	var method_name = FILE_ACTION_EXTENSION + action_text
	
	if has_method(method_name):
		call(method_name)
	else:
		printerr("No such method from file menu implemented, ", action_text)


func popup_dialogue(dialouge : Popup):
	var scale : float = 0.8
	dialouge.popup_centered(scale * get_viewport_rect().size)


func _file_save():
	if save_location == NO_LOCATION_SET:
		popup_dialogue(file_dialogue)
	else:
		emit_signal("save", save_location)
	

func _file_save_as():
	popup_dialogue(file_dialogue)


func _file_open():
	popup_dialogue(open_dialogue)


func _on_SettingsFileDialogue_file_selected(path : String):
	if(!path.ends_with(".JSON")):
		printerr("Can only save to .JSON files")
		return
	
	save_location = path
	get_popup().set_item_tooltip(INDEX.SAVE, path)
	get_popup().set_item_tooltip(INDEX.SAVE_AS, path)
	emit_signal("save", save_location)


func _on_OpenFileDialogue_file_selected(path):
	if(!path.ends_with(".JSON")):
		printerr("Can only read from .JSON files")
		return
	
	emit_signal("open", path)
