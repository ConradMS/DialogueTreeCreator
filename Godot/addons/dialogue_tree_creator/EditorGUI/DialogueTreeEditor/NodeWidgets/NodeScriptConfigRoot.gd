extends Control


const default_path : String = "res://addons/dialogue_tree_creator/Databases/default_scripts.gd"
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

const NAME = 0
const TYPE = 1
var scripts_path : String = default_path
const GD_extension = ".gd"

onready var path_selector = $PathSearcher

func _ready():
	get_args_to_type("test : int , test2 : bool, test3 : String")


func _input(event):
	if event.is_action_pressed("ui_down"):
		$MethodSelector.popup()

func _on_SetPath_pressed():
	path_selector.popup()


func _on_SearchPath_pressed():
	if !scripts_path.ends_with(GD_extension):
		printerr("Node script path incorrectly set to non-gd script file")
		scripts_path = default_path
	
	var script : GDScript = load(scripts_path)
	
	$MethodSelector.update_methods(get_method_details(script.source_code))
	


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
	

func _on_PathSearcher_file_selected(path : String):
	if !path.ends_with(GD_extension):
		printerr("Node script path must be a gd script file")
		return
	scripts_path = path
	
