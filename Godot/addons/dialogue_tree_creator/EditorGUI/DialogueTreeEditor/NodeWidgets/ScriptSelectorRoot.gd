extends Control

onready var nodescript_config_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeScriptConfigRoot.tscn")
onready var vbox = $VBoxContainer

func _on_TextureButton_pressed():
	add_nodescript_config()


func add_nodescript_config():
	var instance = nodescript_config_scene.instance()
	vbox.add_child(instance)


func export_all_method_details() -> String:
	var methods = []
	for child in vbox.get_children():
		if child is NodeMethodConfig:
			methods.append(child.export_method_details())
	return to_json(methods)
