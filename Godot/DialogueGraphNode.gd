extends GraphNode
class_name GraphDialogueNode


onready var dialogueLinesBox = $Lines
onready var characterNameBox = $CharacterSearchBar/CharLabel
onready var expressionList = $ExpressionList
const MIN_NODE_OPTIONS_SIZE = Vector2(150, 150)
const SPACE_BETWEEN_SLOTS = 1

var node_title : String = "Dialogue Node, ID : "

var link_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.tscn")

### Dialogue Node Varaibles ###
var id : int
var expr : String 
var char_name : String
var lines : String
### Dialogue Node Varaibles ###

func init(id_input : int):
	if id_input == null:
		printerr("id for a tree node should never be null")
		node_title += "null"
	else:
		node_title += String(id)
	title = node_title

func _ready():
	var status = connect("resize_request", self, "_resize")
	if status != OK:
		printerr("DialogueGraphNode Line 29, Error: ", status)
		
	var status_2 = connect("focus_exited", self, "_update_lines")
	if status_2 != OK:
		printerr("DialogueGraphNode Line 33, Error: ", status_2)
	
	# CHANGE THIS when autocomplete from a list is added
	#
	#
	#
	#
	var status_3 = connect("focus_exited", self, "_update_character_name")
	if status_3 != OK:
		printerr("DialogueGraphNode Line 38, Error: ", status_3)

func _update_lines():
	if dialogueLinesBox.text != dialogueLinesBox.DEFAULT_TEXT:
		lines = dialogueLinesBox.text
		
func _update_character_name():
	if characterNameBox.text != characterNameBox.DEFAULT_TEXT:
		char_name = characterNameBox.DEFAULT_TEXT


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
	var link = link_scene.instance()
	link.connect("remove_link", self, "_remove_link")
	rect_size.y += link.rect_size.y + SPACE_BETWEEN_SLOTS
	self.add_child(link)


func _remove_link():
	print("remove!")
