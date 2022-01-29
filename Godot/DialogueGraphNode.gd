extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/TreeNode.gd"
class_name GraphDialogueNode

onready var dialogueLinesBox : TextEdit = $Lines
onready var characterNameBox = $CharacterSearchBar/CharLabel
onready var characterSearchBar = $CharacterSearchBar
onready var expressionList = $ExpressionList
const DIALOGUE_NODE_NAME = "Dialogue node, id: "
const MIN_NODE_OPTIONS_SIZE = Vector2(150, 150)
### Dialogue Node Varaibles ###
var expr : String 
var char_name : String
var lines : String
### Dialogue Node Varaibles ###

signal sync_recents(recents)


func _ready():
	create_title(DIALOGUE_NODE_NAME)
	type = DialogueTreeVariableNames.NODE_TYPES.DIALOGUE_NODE
	
	characterSearchBar.build_suggestions_tab("res://addons/dialogue_tree_creator/Databases/default_characters.txt")
	expressionList.build_expression_list("res://addons/dialogue_tree_creator/Databases/default_expressions.txt")
	
	var status = connect("resize_request", self, "_resize")
	if status != OK:
		printerr("DialogueGraphNode Line 29, Error: ", status)
		
	var status_2 = dialogueLinesBox.connect("text_changed", self, "_update_lines")
	if status_2 != OK:
		printerr("DialogueGraphNode Line 33, Error: ", status_2)
		
	var status_3 = 	characterNameBox.connect("text_changed", self, "_update_character_name")
	if status_3 != OK:
		printerr("DialogueGraphNode Line 38, Error: ", status_3)
	
	characterNameBox.connect("add_recent", self, "ping_recents")
	
	_add_link()


func _update_lines():
	if dialogueLinesBox.text != dialogueLinesBox.DEFAULT_TEXT:
		lines = dialogueLinesBox.text

		
func _update_character_name():
	if characterNameBox.text != characterNameBox.DEFAULT_TEXT:
		char_name = characterNameBox.text


func _resize(new_size = Vector2(0, 0)):
	var rescale_size = new_size
	if new_size.x < MIN_NODE_OPTIONS_SIZE.x:
		rescale_size.x = MIN_NODE_OPTIONS_SIZE.x
	
	if new_size.y < MIN_NODE_OPTIONS_SIZE.y:
		rescale_size.y = MIN_NODE_OPTIONS_SIZE.y
	
	rect_size = rescale_size


func _on_ExpressionList_item_selected(index):
	expr = expressionList.get_item_text(index)


func _on_AddLinkButton_pressed():
	_add_link()


func sync_recent_searches(recents : PoolStringArray):
	characterSearchBar.sync_recents(recents)
	
	
func ping_recents(recent):
	emit_signal("sync_recents", recent)
	

func get_var_dict():
	var var_dict = .get_var_dict()
	var_dict[DialogueTreeVariableNames.DIALOGUE_NODE_VARS.LINES] = lines
	var_dict[DialogueTreeVariableNames.DIALOGUE_NODE_VARS.CHARACTER] = char_name
	var_dict[DialogueTreeVariableNames.DIALOGUE_NODE_VARS.EXPRESSION] = expr
	
	return var_dict
