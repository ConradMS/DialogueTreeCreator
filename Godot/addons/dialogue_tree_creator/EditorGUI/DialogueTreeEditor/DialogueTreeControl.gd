extends Control
class_name DialogueTreeControl

onready var addNodeMenu = $VSplitContainer/OptionsBar/HBoxContainer/AddnodeMenu
onready var dialogueTree : DialogueTree = $VSplitContainer/DialogueTree
onready var warningBox = $WarningMessage 

onready var fileMenu = $VSplitContainer/OptionsBar/HBoxContainer/FileMenu
onready var settingsMenu = $VSplitContainer/OptionsBar/HBoxContainer/SettingsMenu2
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
	added_node.update_paths(settingsMenu.paths)
	
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
	
	dialogueTree.construct_dialogue_tree(nodes)
	add_imported_information(nodes)
#	validate_nodes(nodes)

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
			add_link_information(node, flags_used)
			
	return flags_used


func add_link_information(node : TreeNode, conds : PoolStringArray):
	for link in node.links.values():
		if link is Link:
			for condition in link.conditions:
				if !(condition in conds):
					conds.append(condition)
