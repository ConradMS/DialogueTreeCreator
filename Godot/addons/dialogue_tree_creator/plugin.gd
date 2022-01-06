tool
extends EditorPlugin


#var dock = preload("res://addons/dialogue_tree_creator/EditorGUI/MainScreen/PopupMenu.tscn").instance()
const mainPanel = preload("res://addons/dialogue_tree_creator/EditorGUI/MainScreen/MainGraphEditMenu.tscn")
const SCREEN_NAME = "Dialogue Tree Creator"

var main_panel_instance

func _enter_tree():
	main_panel_instance = mainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
#	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)


func _exit_tree():
	# runs if main_panel_instance is not null
	if main_panel_instance:
		main_panel_instance.queue_free()
#	remove_control_from_docks(dock)
#	dock.queue_free()

func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return SCREEN_NAME


func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
