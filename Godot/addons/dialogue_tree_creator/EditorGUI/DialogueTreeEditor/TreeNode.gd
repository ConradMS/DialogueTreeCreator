extends GraphNode
class_name TreeNode

const ROOT_ID = 0
var type : String = "Not defined"
var id : int = -1
var links : Dictionary = {}
var link_scene : PackedScene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.tscn")
const SPACE_BETWEEN_SLOTS = 1

signal remove_node(id)

func init(id_i : int):
	id = id_i
	self.connect("close_request", self, "delete_self")


func delete_self():
	emit_signal("remove_node", id)
	

func _input(event):
	if Input.is_key_pressed(KEY_BACKSPACE):
		if selected and !editing_children():
			delete_self()


func build_from_var_dict(var_dict : Dictionary) -> bool:
	var required_vars : Array = DialogueTreeVariableNames.TREE_NODE_VARS.values()
	var ok = true
	if !(var_dict.has_all(required_vars)):
		printerr("Node does not have all the required tree node variables")
		ok = false
		return ok

	var id_var = var_dict[DialogueTreeVariableNames.TREE_NODE_VARS.ID]
	var type_var = var_dict[DialogueTreeVariableNames.TREE_NODE_VARS.TYPE]
	var links_var = var_dict[DialogueTreeVariableNames.TREE_NODE_VARS.LINKS]
	
	id_var = int(id_var) if id_var is float else id_var
	
	if !(id_var is int and type_var is String):
		printerr("Tree node varaibles are not the required type")
		ok = false
	
	id = id_var
	type = type_var
	ok = ok and validate_links_var(links_var)
	
	if links_var is Dictionary:
		for key in links_var.keys():
			if !(key is int):
				printerr("Key is not of type int")
				ok = false
			
			var new_link : Link = link_scene.instance()
			var status = new_link.build_from_var_dict(links_var[key])
			
			ok = status if !status else ok
			links[key] = new_link
	else:
		printerr("Set of links is not a dictionary")
		ok = false
	
	return ok

func validate_links_var(links_var : Dictionary) -> bool:
	var num_regex = RegEx.new()
	num_regex.compile("[0-9]+")

	var ok = true
	for key in links_var.keys():
		if(key is String):
			var reg_match : RegExMatch = num_regex.search(key)
			var res : String = reg_match.get_string()
			
			if res == key:
				links_var[int(key)] = links_var[key]
				links_var.erase(key)
			else:
				ok = false
	return ok
	

func sync_graph_node():
	for link in links.values():
		if link is Link:
			link.sync_link()


func editing_children() -> bool:
	var editing = false
	for child in get_children():
		if child is Control:
			if child.has_focus():
				editing = true
	return editing 


func create_title(node_title : String):
	if id == null:
		printerr("id for a tree node should never be null")
		node_title += "null"
	else:
		if id == ROOT_ID:
			node_title += "ROOT"
		else:
			node_title += String(id)
	title = node_title
	

func get_var_dict():
	var vars : Dictionary = {}
	vars[DialogueTreeVariableNames.TREE_NODE_VARS.ID] = id
	vars[DialogueTreeVariableNames.TREE_NODE_VARS.LINKS] = {}
	vars[DialogueTreeVariableNames.TREE_NODE_VARS.TYPE] = type
	for link_i in links.values():
		if link_i is Link:
			var key = link_i.id
			vars[DialogueTreeVariableNames.TREE_NODE_VARS.LINKS][key] = link_i.get_var_dict()
		else:
			printerr("Object not of type Link in links")
	return vars
	

func toJSON() -> String:
	return to_json(get_var_dict())


func _add_link():
	var link = get_link_scene().instance()
	if !(link is Link):
		printerr("Cannot add link, link resource path is not a subtype of link")
		return
	
	var link_id = get_next_free_id()
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
		

func get_link_scene() -> PackedScene:
	var packed_scene : PackedScene = load("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/Link.tscn")
	return packed_scene


func update_paths(paths : Dictionary):
	for link in links.values():
		if link is Link:
			link.build_conditions_list(paths[DialogueTreeConfig.configureable_paths.CONDITIONS])


func get_next_free_id() -> int:
	var next_id = 0
	while next_id in links:
		next_id += 1
	return next_id

