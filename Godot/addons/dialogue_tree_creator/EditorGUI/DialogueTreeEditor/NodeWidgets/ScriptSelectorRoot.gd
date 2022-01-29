extends Control

onready var nodescript_config_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeScriptConfigRoot.tscn")
onready var vbox = $VBoxContainer
onready var base_components = $VBoxContainer/ScriptAdder
const SIZE_BUFFER = 5 

func _on_TextureButton_pressed():
	add_nodescript_config()


func add_nodescript_config():
	var instance = nodescript_config_scene.instance()
	instance.connect("min_size_change", self, "update_min_size")
	vbox.add_child(instance)
	update_min_size()


func export_all_method_details() -> Array:
	var methods = []
	for child in vbox.get_children():
		if child is NodeMethodConfig:
			methods.append(child.export_method_details())
	return methods
	
	
func update_min_size():
	var min_size = 0
	for child in base_components.get_children():
		if child.rect_size.y > min_size:
			min_size = child.rect_size.y
			
	for child in vbox.get_children():
		if child is NodeMethodConfig:
			min_size += child.rect_min_size.y + SIZE_BUFFER
	self.rect_min_size.y = min_size
