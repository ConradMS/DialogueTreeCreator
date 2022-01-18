extends "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/TreeNode.gd"
class_name GraphDialogueNode

onready var dialogueLinesBox : TextEdit = $Lines
onready var characterNameBox = $CharacterSearchBar/CharLabel
onready var characterSearchBar = $CharacterSearchBar
onready var expressionList = $ExpressionList
const MIN_NODE_OPTIONS_SIZE = Vector2(150, 150)
const SPACE_BETWEEN_SLOTS = 1
const ROOT_ID = 0

var node_title : String = "Dialogue Node, ID : "

var link_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.tscn")

### Dialogue Node Varaibles ###
var expr : String 
var char_name : String
var lines : String
### Dialogue Node Varaibles ###

signal sync_recents(recents)

func create_title():
	if id == null:
		printerr("id for a tree node should never be null")
		node_title += "null"
	else:
		if id == ROOT_ID:
			node_title += "ROOT"
		else:
			node_title += String(id)
	title = node_title

func _ready():
	create_title()
	characterSearchBar.build_suggestions_tab("res://addons/dialogue_tree_creator/Databases/default_characters.txt")
	var status = connect("resize_request", self, "_resize")
	if status != OK:
		printerr("DialogueGraphNode Line 29, Error: ", status)
		
	var status_2 = dialogueLinesBox.connect("text_changed", self, "_update_lines")
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
	
	characterNameBox.connect("add_recent", self, "ping_recents")
	
	_add_link()


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
	_add_link()


func _add_link():
	var link = link_scene.instance()
	var link_id = links.size()
	link.init(link_id)
	link.connect("remove_link", self, "_remove_link")
	link.connect("change_priority", self, "find_priority_dir")
	
	rect_size.y += link.rect_size.y + SPACE_BETWEEN_SLOTS
	links[link_id] = link
	
	self.add_child(link)
	_fit_priority(link)
	_add_link_slot()


func is_unique_priority(value : int) -> bool:
	var unique = true
	for existing_link in links.values():
		if existing_link.priority == value:
			unique = false
	return unique


func find_priority_dir(old : int, new : int, link : Link):
	# dir is -1 if new decreased and 1 if it increases
	if is_unique_priority(new):
		link.set_priority(new)
		return
	
	var dir = (new - old) / abs(new - old)
	
	while !is_unique_priority(new) and link.is_in_priorty_range(new):
		new += dir
	
	if is_unique_priority(new) and link.is_in_priorty_range(new):
		link.set_priority(new)
	else:
		_fit_priority(link)


func _fit_priority(link : Link):
	var least_prority = 0
	for existing_link in links.values():
		if !(existing_link is Link):
			printerr("Object not of type link in dialogue nodes Links")
		
		if (existing_link != link):
			if existing_link.priority >= least_prority:
				least_prority = existing_link.priority + 1
	
	link.set_priority(least_prority)
	

"""
Only called after adding a new link
"""
func _add_link_slot():
	var slot_nums = get_child_count()
	set_slot_enabled_right(slot_nums - 1, true)


func _remove_link(link_id : int):
	if links.size() == 1:
		print("You must have at least one link!")
		return
	
	if !links.has(link_id):
		printerr("trying to remove a non-existant link")
	else:
		rect_size.y -= links[link_id].rect_size.y + SPACE_BETWEEN_SLOTS
		links[link_id].queue_free()
		#warning-ignore: return_value_discarded
		links.erase(link_id)


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
