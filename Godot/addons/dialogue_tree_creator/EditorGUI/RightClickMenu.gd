tool
extends Node

var popupMenu = preload("res://addons/dialogue_tree_creator/EditorGUI/RightClickMenu.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("true")
