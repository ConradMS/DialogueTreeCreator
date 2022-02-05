extends MenuButton
class_name DialogueTreeConfig

const config_option = "Configure Paths"
const configureable_paths := {
	CHARACTERS = "Characters",
	EXPRESSIONS = "Expressions",
	CONDITIONS  = "Conditions",
	THEMES = "Themes"
}

var paths = {
	configureable_paths.CHARACTERS: "res://addons/dialogue_tree_creator/Databases/default_characters.txt",
	configureable_paths.EXPRESSIONS: "res://addons/dialogue_tree_creator/Databases/default_expressions.txt",
	configureable_paths.CONDITIONS: "res://addons/dialogue_tree_creator/Databases/default_conditions.txt",
	configureable_paths.THEMES: "No Path",
}

var configSubmenu = PopupMenu.new()
var path_to_edit = "none"

signal update_paths(paths)
onready var pathSelector = $PathSelector
var popupMenu : PopupMenu

func _ready():
	popupMenu = get_popup()
	_create_paths_submenu()


func _create_paths_submenu():
	for type in configureable_paths.values():
		configSubmenu.add_item(type)
	
	popupMenu.add_child(configSubmenu)
	var path = popupMenu.get_path_to(configSubmenu)
	popupMenu.add_submenu_item(config_option, path)
	
	configSubmenu.connect("index_pressed", self, "_handle_path_change")
	_update_tooltips()


func _handle_path_change(path_index : int):
	pathSelector.popup()
	path_to_edit = configSubmenu.get_item_text(path_index)


func _update_tooltips():
	for index in range(0, configSubmenu.get_item_count()):
		var text = configSubmenu.get_item_text(index)
		if paths.has(text):
			configSubmenu.set_item_tooltip(index, paths[text])


func _on_PathSelector_file_selected(path):
	if paths.has(path_to_edit):
		paths[path_to_edit] = path
		_update_tooltips()
		emit_signal("update_paths", paths)
	else:
		printerr("Trying to edit non-existant path type")
