extends GraphEdit
class_name DialogueTree


const NODE_TYPES = {
	DIALOGUE_NODE = 0,
	DYNAMIC_NODE = 1,
	CHOICE_NODE = 2
}

const NODE_REFERENCES = {
	NODE_TYPES.DIALOGUE_NODE: preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/DialogueNode.tscn"),
	NODE_TYPES.DYNAMIC_NODE: preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/DialogueNode.tscn"),
	NODE_TYPES.CHOICE_NODE: preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/DialogueNode.tscn")
}
var nodes : Dictionary = {}
var recentSearches : PoolStringArray
const MAX_RECENTS = 5

const FIRST_SLOT = 0
const ROOT = 0


func add_recent(recent : String):
	recentSearches.insert(0, recent)
	if recentSearches.size() > MAX_RECENTS:
		recentSearches.remove(recentSearches.size() - 1)
	
	sync_recents()


func sync_recents():
	for node in nodes.values():
		if node is GraphDialogueNode:
			node.sync_recent_searches(recentSearches)


func add_node(type : int) -> int:
	var node_scene : PackedScene = NODE_REFERENCES[type]
	var new_node : TreeNode = node_scene.instance()
	
	if new_node is GraphDialogueNode:
		new_node.connect("sync_recents", self, "add_recent")
	
	var new_id = get_next_avaliable_id()
	
	new_node.init(new_id)
	nodes[new_id] = new_node
	self.add_child(new_node)
	new_node.connect("remove_node", self, "remove_node")
	
	sync_recents()
	return new_node.id


func get_next_avaliable_id() -> int:
	var next_id = 0
	while next_id in nodes.keys():
		next_id += 1
	return next_id


func get_node_by_name(node_name : String) -> TreeNode:
	for node in nodes.values():
		if node.name == node_name:
			return node
	
	printerr("No such node:", node_name, "found in ", nodes)
	return null


func _on_DialogueTree_connection_to_empty(from, from_slot, release_position):
	# For now create a dialouge node, change later
	var added_node_id : int = add_node(0)
	var added_node : GraphNode = nodes.get(added_node_id)
	
	added_node.offset = (release_position + scroll_offset) / zoom
	added_node.offset.y -= added_node.rect_size.y / 2
	
	var from_node = get_node_by_name(from)
	
	connect_nodes(from_node.name, from_slot, added_node.name, FIRST_SLOT)


func node_has_connection(node : String, from_slot):
	var connections = get_connection_list()
	for connection in connections:
		if connection["from"] == node and connection["from_port"] == from_slot:
			return connection
	return null


func connect_nodes(from : String, from_slot, to : String, to_slot):
	var possible_connection = node_has_connection(from, from_slot)
	if possible_connection != null:
		disconnect_nodes(possible_connection["from"], possible_connection["from_port"], possible_connection["to"], possible_connection["to_port"])
	
	connect_node(from, from_slot, to, to_slot)
	add_link_info(from, from_slot, to)


func _on_DialogueTree_connection_request(from, from_slot, to, to_slot):
	connect_nodes(from, from_slot, to, to_slot)


func is_root_node(node : TreeNode):
	return node.id == ROOT


func remove_node(id):
	var node_to_remove : TreeNode = nodes[id]
	if is_root_node(node_to_remove):
		print("Cannot Delete Root!")
		return
	
	disconnect_all_connections(node_to_remove.name)
	nodes.erase(id)
	node_to_remove.queue_free()


func has_any_connections(node : String):
	var connections = get_connection_list()
	for connection in connections:
		if connection["from"] == node or connection["to"] == node:
			return true
	return false


func disconnect_all_connections(node : String):
	var connections = get_connection_list()
	for connection in connections:
		if connection["from"] == node or connection["to"] == node:
			disconnect_nodes(connection["from"], connection["from_port"], connection["to"], connection["to_port"])


func disconnect_nodes(from : String, from_slot, to : String, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
	remove_link_info(from, from_slot)
	

func add_link_info(from : String, from_slot, to : String):
	var from_node = get_node_by_name(from)
	var from_link : Link = from_node.links[from_slot]
	from_link.linked_id = get_node_by_name(to).id
	

func remove_link_info(from : String, from_slot):
	var from_node = get_node_by_name(from)
	var from_link : Link = from_node.links[from_slot]
	from_link.linked_id = -1
	
