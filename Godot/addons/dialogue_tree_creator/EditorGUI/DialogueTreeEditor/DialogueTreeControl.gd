extends Control
class_name DialogueTreeControl

onready var addNodeMenu = $VSplitContainer/OptionsBar/HBoxContainer/AddnodeMenu
onready var dialogueTree : DialogueTree = $VSplitContainer/DialogueTree
onready var warningBox = $WarningMessage 

onready var fileMenu = $VSplitContainer/OptionsBar/HBoxContainer/FileMenu
onready var settingsMenu = $VSplitContainer/OptionsBar/HBoxContainer/SettingsMenu2

onready var top_bar = $VSplitContainer/OptionsBar/HBoxContainer
var mouseMenu : PopupMenu
const FILE_MENU_EXTENSION = "_file_"

const IMPORTS = {
	EXPRESSIONS = "expressions",
	NAMES = "names",
	CONDITIONS = "conditions"
}

var import_info = {
	IMPORTS.EXPRESSIONS: [],
	IMPORTS.NAMES: [],
	IMPORTS.CONDITIONS: []
}

const CENTER_SCREEN = Vector2(640, 320)
# Called when the node enters the scene tree for the first time.
func _ready():
	var addNodePopup : PopupMenu = addNodeMenu.get_popup()
	mouseMenu = _copy_popup(addNodePopup)
	addNodePopup.connect("index_pressed", self, "_add_node")
	mouseMenu.connect("index_pressed", self, "_add_node", [true])
	
	dialogueTree.connect("warn", self, "add_warning")
	settingsMenu.connect("update_paths", dialogueTree, "update_node_paths")
	

func _copy_popup(popup : PopupMenu) -> PopupMenu:
	var newPopup = PopupMenu.new() 
	self.add_child(newPopup)
	newPopup.items = popup.items
	return newPopup
	

func _add_node(type : int, use_mouse_position : bool = false):
	var added_id : int = dialogueTree.add_node(type)
	var added_node : TreeNode = dialogueTree.nodes[added_id]
	update_node_imports([added_node])
	
	if use_mouse_position:
		added_node.offset = (get_global_mouse_position() + dialogueTree.scroll_offset) / dialogueTree.zoom
		added_node.offset.y -= added_node.rect_size.y / 2


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed == true:
			if !(mouseMenu == null):
				mouseMenu.popup()
				mouseMenu.rect_position = get_global_mouse_position() 


func add_warning(warning : String):
	warningBox.create_message_popup(warning, Vector2(640, 320))


func _on_FileMenu_save(path):
	var lines = dialogueTree.export_dialogue_tree()
	
	var file : File = File.new()
	file.open(path, file.WRITE)
	for line in lines:
		file.store_line(line)
	
	print("File Saved to: ", path)


func _on_FileMenu_open(path):
	var MIN_LENGTH = 2
	
	var file : File = File.new()
	file.open(path, file.READ)
	
	# Array of TreeNodes
	var nodes = [] 
	
	var next_line = ""
	while !(file.eof_reached()):
		next_line = file.get_line()
		
		if next_line.length() < MIN_LENGTH:
			break
		
		var status = validate_json(next_line)
		
		if status != "":
			printerr("Not valid JSON data")
			return
		
		var var_dict = JSON.parse(next_line).result
		if !(var_dict is Dictionary):
			printerr("JSON is not a dialogue tree")
			return 
		
		var new_node : TreeNode = dialogueTree.build_node(var_dict)
		if new_node == null:
			printerr("Malformed JSON to create dialogue tree")
			return
		
		nodes.append(new_node)
	
	#	validate_nodes(nodes)
	dialogueTree.construct_dialogue_tree(nodes)
	# Have to finish for conditions 
	add_imported_information(nodes)
	# Have to finish for selecting conditions and also node scripts for dynamic nodes
	sync_nodes(nodes)
	space_nodes(nodes)
	connect_nodes(nodes)


# Here check to make sure nodes are formatted correctly, i.e. if all
# links link to an existing node and what not, If there are formatting issues
# Display them, and a popup warning the user, with an option to proccede 
func validate_nodes(nodes : Array):
	pass
	

func add_imported_information(nodes : Array):
	var used_names = collect_name_imports(nodes)
	var expressions_used = collect_expression_imports(nodes)
	var conditions_used = collect_flag_imports(nodes)
	
	import_info[IMPORTS.NAMES] = used_names
	import_info[IMPORTS.EXPRESSIONS] = expressions_used
	import_info[IMPORTS.CONDITIONS] = conditions_used
	
	update_node_imports(nodes)


func update_node_imports(nodes : Array):
	for node in nodes:
		if node is TreeNode:
			node.add_condition_import_info(import_info[IMPORTS.CONDITIONS])
		
		if node is GraphDialogueNode:
			node.add_name_import_info(import_info[IMPORTS.NAMES])
			node.add_expression_import_info(import_info[IMPORTS.EXPRESSIONS])
		
		if node is DynamicNode:
			pass
		
		
		if node is ChoiceNode:
			pass


func collect_name_imports(nodes : Array):
	var names_used : PoolStringArray = []
	for node in nodes:
		if node is GraphDialogueNode:
			if !(node.char_name in names_used):
				names_used.append(node.char_name)
				
	return names_used
	

func collect_expression_imports(nodes : Array):
	var expressions_used : PoolStringArray = []
	for node in nodes:
		if node is GraphDialogueNode:
			if !(node.expr in expressions_used):
				expressions_used.append(node.expr)
	
	return expressions_used


func collect_flag_imports(nodes : Array):
	var flags_used : PoolStringArray = []
	for node in nodes:
		if node is TreeNode:
			flags_used.append_array(add_link_information(node))
			
	return flags_used


func add_link_information(node : TreeNode) -> PoolStringArray:
	var new_conds = []
	for link in node.links.values():
		if link is Link:
			for condition in link.conditions:
				if !(condition in new_conds):
					new_conds.append(condition)
	return new_conds


func sync_nodes(nodes : Array):
	for node in nodes:
		if node is TreeNode:
			node.sync_graph_node()


func space_nodes(nodes : Array):
	if (nodes.size() < 2):
		print("Not enough nodes to space / Nodes are not type treenode")
		return
	
	var node_dict = get_node_dict(nodes)
	var root = get_root(nodes)
	var placed = []
	
	place_children(root, placed, node_dict)
	
	var mag_between_nodes = 100
	
	for node in nodes:
		if node is TreeNode:
			if !(node in placed):
				var node_offset = get_new_node_position(mag_between_nodes, 0, node, node, placed)
				
				move_node(node_offset, node)
				place_children(node, placed, node_dict)


func place_children(parent : TreeNode, placed : Array, node_dict : Dictionary):
	if parent in placed:
		return
	
	placed.append(parent)
	var spawn_region_size = PI / 2 
	var num_links = parent.links.values().size()
	
	var rotation_per_node = spawn_region_size / num_links
	
	var mag_between_nodes = 100
	var count = 0
	for link in parent.links.values():
		if link is Link:
			if node_dict.has(link.linked_id):
				var linked_node = node_dict[link.linked_id]
				
				if !(linked_node in placed):
					var node_offset = get_new_node_position(mag_between_nodes, rotation_per_node * count, parent, linked_node, placed)
					
					move_node(node_offset, linked_node)
					place_children(linked_node, placed, node_dict)
		count += 1


func get_new_node_position(init_magnitute : float , init_rotation : float , parent : TreeNode, node : TreeNode, placed : Array) -> Vector2:
	var mag = init_magnitute
	var rotation = init_rotation
	var init_offset = calculate_offset(init_magnitute, init_rotation)
	
	var size = node.rect_size
	var offset = parent.offset + calculate_offset(mag, rotation)
	
	while overlaps_any(offset, size, placed):
		if init_rotation == 0:
			init_rotation = - PI/2
		else:
			mag += init_magnitute
		
		offset = parent.offset + calculate_offset(mag, rotation)
	return offset


func calculate_offset(magnitude : float, rotation : float) -> Vector2:
	return Vector2(magnitude * cos(rotation), magnitude * sin(rotation))


func overlaps_any(offset : Vector2, size : Vector2, placed : Array) -> bool:
	var overlaps = false
	for node in placed:
		if node is TreeNode:
			overlaps = overlaps or is_overlapping(offset, size, node.offset, node.rect_size)
	
	return overlaps


func is_overlapping(pos1 : Vector2, size1 : Vector2, pos2 : Vector2, size2: Vector2) -> bool:
	var overlaps_x = false
	if pos1.x + size1.x > pos2.x and pos2.x + size2.x > pos1.x:
		overlaps_x = true
	
	var overlaps_y = false
	if pos1.y + size1.y > pos2.y and pos2.y + size2.y > pos1.y:
		overlaps_y = true
	
	return overlaps_x and overlaps_y


func get_node_dict(nodes : Array):
	var dict : Dictionary = {}
	for node in nodes:
		if node is TreeNode:
			dict[node.id] = node
	
	return dict


func get_root(nodes : Array):
	for node in nodes:
		if node is TreeNode:
			if node.id == DialogueTree.ROOT:
				return node
	
	printerr("No root in nodes")
	return nodes[0]


func move_node(position : Vector2, node : TreeNode):
	node.offset = position


func connect_nodes(nodes : Array):
	var node_dict : Dictionary = get_node_dict(nodes)
	
	for node in nodes:
		if node is TreeNode:
			for link in node.links.values():
				if link is Link:
					connect_from_link(node, link, node_dict)


func connect_from_link(from_node : TreeNode, link : Link, node_dict : Dictionary):
	var to_id = link.linked_id
	# Need to init the links
	if to_id < 0:
		return
		
	if !(node_dict.has(to_id)):
		printerr("Link connects to non-existant id")
		return
	
	var to_node = node_dict[to_id]
	var from_slot = link.id
	dialogueTree.connect_nodes(from_node.name, from_slot, to_node.name, 0)


func _on_DialogueTreeControl_visibility_changed():
	var process = visible
	set_process_input(process)
	update_process_input(process)
	

func update_process_input(process : bool):
	dialogueTree.set_process_input(process)
	dialogueTree.update_nodes_process_input(process)
	top_bar.set_process_input(process)
