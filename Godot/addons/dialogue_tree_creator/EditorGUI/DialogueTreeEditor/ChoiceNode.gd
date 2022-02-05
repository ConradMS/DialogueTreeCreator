extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/TreeNode.gd"
class_name ChoiceNode
const MIN_SIZE = Vector2(200, 100)
const CHOICE_NODE = "Choice Node, id: "

var choice_hint : String = ""
onready var choice_link_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/ChoiceLink.tscn")
onready var textbox = $TextEdit

func _ready():
	create_title(CHOICE_NODE)
	type = DialogueTreeVariableNames.NODE_TYPES.CHOICE_NODE


func _on_ChoiceNode_resize_request(new_minsize):
	rect_size = Vector2(max(MIN_SIZE.x, new_minsize.x), max(MIN_SIZE.y, new_minsize.y))


func _on_ChoiceNode_close_request():
	queue_free()


func _on_AddLinkButton_pressed():
	_add_link()


func get_link_scene() -> PackedScene:
	var packed_scene : PackedScene = load("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/ChoiceLink.tscn")
	return packed_scene
	

func get_var_dict() -> Dictionary:
	var var_dict = .get_var_dict()
	var_dict[DialogueTreeVariableNames.CHOICE_NODE_VARS.CHOICE_HINT] = choice_hint
	return var_dict 


func _on_TextEdit_text_changed():
	if textbox.text == textbox.DEFAULT_TEXT:
		choice_hint = ""
	else:
		choice_hint = textbox.text
