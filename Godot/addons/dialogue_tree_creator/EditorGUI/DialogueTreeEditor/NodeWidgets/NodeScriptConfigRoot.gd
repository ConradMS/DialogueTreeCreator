extends Control
class_name NodeMethodConfig

const default_path : String = "res://addons/dialogue_tree_creator/Databases/default_scripts.gd"
onready var param_location = $VBoxContainer/Params
onready var method_selector = $MethodSelector
onready var base_components = $VBoxContainer/HBoxContainer
const UNKNOWN = "variant"
const plain_text_to_type : Dictionary = {
	"int": TYPE_INT,
	"float": TYPE_REAL,
	"bool": TYPE_BOOL,
	"Vector2": TYPE_VECTOR2,
	"Array": TYPE_ARRAY,
	"String": TYPE_STRING,
	"Color": TYPE_COLOR,
	UNKNOWN: TYPE_STRING
}

const method_parts = {
	DESCRIPTION = "description",
	HEADER = "header",
	ARGS = "args",
	RETURN_TYPE = "return_type",
	NAME = "name"
}

const param_referecnes = {
	TYPE_INT: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/IntParam.tscn",
	TYPE_REAL: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/FloatParam.tscn",
	TYPE_STRING: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/StringParam.tscn",
	TYPE_ARRAY: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/ArrayParam.tscn",
	TYPE_BOOL: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/BoolParam.tscn",
	TYPE_VECTOR2: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/Vector2Param.tscn",
	TYPE_COLOR: "res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/NodeWidgets/NodeParams/ColorParam.tscn"
}

const NAME = 0
const TYPE = 1
var scripts_path : String = default_path
const GD_extension = ".gd"

onready var path_selector = $PathSearcher

func _ready():
	load_methods_from_path()
	set_minimum_size()


func _on_SetPath_pressed():
	path_selector.popup()


func _on_SearchPath_pressed():
	method_selector.popup()
	

func set_minimum_size():
	var min_size = Vector2(0, 0)
	for child in base_components.get_children():
		if child.rect_size.y > min_size.y:
			min_size.y = child.rect_size.y
	
	for child in param_location.get_children():
		if child is NodeScriptParam:
			min_size.y += child.get_minimum_size().y
	
	rect_min_size = Vector2(rect_size.x, min_size.y)


func get_method_details(source_code : String):
	var function_regex = RegEx.new()
	function_regex.compile("(\"\"\"(?<description>(\n.*)?)\n+\"\"\"\n)?func +(?<header>(?<name>[A-z_]+[A-z0-9_]+)\\((?<args>.*)\\)) *(->)? *(?<return_type>.*):")
	var result : Array = function_regex.search_all(source_code)
	# Methods are stored in an array, holds, header: retrun type name(args), args: Dict from arg name to type, description of function
	var methods : Array 
	
	for res in result:
		var method_dict : Dictionary = {}
		method_dict[method_parts.DESCRIPTION] = res.get_string(method_parts.DESCRIPTION).strip_escapes()
		var return_type_string = res.get_string(method_parts.RETURN_TYPE)
		
		if return_type_string.length() > 0:
			method_dict[method_parts.HEADER] = return_type_string + " " + res.get_string(method_parts.HEADER)
		else:
			method_dict[method_parts.HEADER] = res.get_string(method_parts.HEADER)
		
		method_dict[method_parts.ARGS] = get_args_to_type(res.get_string(method_parts.ARGS))
		method_dict[method_parts.NAME] = res.get_string(method_parts.NAME)
		
		methods.append(method_dict)
	
	return methods


func get_args_to_type(args : String):
	var names_to_type : Dictionary = {}
	
	if args.length() == 0:
		return names_to_type
	
	var indvidual_args : PoolStringArray = args.split(",")
	for arg in indvidual_args:
		var name_and_type = parse_var(arg)
		if names_to_type.has(name_and_type[NAME]):
			printerr("Duplicate name in arg list")
		else:	
			names_to_type[name_and_type[NAME]] = name_and_type[TYPE]
	
	return names_to_type


func parse_var(arg : String):
	arg = arg.rstrip(" ").lstrip(" ")
	var name_and_type : PoolStringArray = arg.split(":")
	
	for i in range(0, name_and_type.size()):
		name_and_type[i] = name_and_type[i].rstrip(" ").lstrip(" ")
	
	if name_and_type.size() < 2:
		return [name_and_type[NAME], plain_text_to_type[UNKNOWN]]
	
	if !plain_text_to_type.has(name_and_type[TYPE]):
		printerr("Unknown type: ", name_and_type[TYPE])
		return [name_and_type[NAME], plain_text_to_type[UNKNOWN]]
	
	return [name_and_type[NAME], plain_text_to_type[name_and_type[TYPE]]]


func load_methods_from_path():
	var script : GDScript = load(scripts_path)
	method_selector.update_methods(get_method_details(script.source_code))
	

func _on_PathSearcher_file_selected(path : String):
	if !path.ends_with(GD_extension):
		printerr("Node script path must be a gd script file")
		return
	scripts_path = path
	load_methods_from_path()


func _on_MethodSelector_method_selected(method : Dictionary):
	for child in param_location.get_children():
		child.queue_free()
	
	for arg in method[method_parts.ARGS]:
		var packed_scene : PackedScene = load(param_referecnes[method[method_parts.ARGS][arg]])
		var node_param : NodeScriptParam = packed_scene.instance()
		node_param.set_info(arg, method[method_parts.ARGS][arg])
		param_location.add_child(node_param)
		
	set_minimum_size()


func export_method_details() -> String:
	var selected_method = method_selector.selected_method
	
	var method_dict = {}
	var args_values = []
	if selected_method.size() > 0:
		method_dict[method_parts.NAME] = selected_method[method_parts.NAME]
		
		for child in param_location.get_children():
			if child is NodeScriptParam:
				args_values.append(child.string_value)
			else:
				printerr("Child of param locations should always be type node script param")
		
		method_dict[method_parts.ARGS] = args_values
	else:
		printerr("saving empty method call")
	
	return to_json(method_dict)


func _on_MinusButton_pressed():
	self.queue_free()
