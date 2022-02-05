extends OptionButton
const default_path : String = "res://addons/dialogue_tree_creator/Databases/default_expressions.txt"
const VALID_FILE_EXTENSION = ".txt"


func _ready():
	build_expression_list(default_path)


func correct_file_type(file_path : String) -> bool:
	if file_path.ends_with(VALID_FILE_EXTENSION):
		return true
	return false


func build_expression_list(file_path : String):
	var file = File.new()
	if !(file.file_exists(file_path)):
		printerr("file_path: ", file_path, " does not exist to build expressions list")
		return
	
	if !(correct_file_type(file_path)):
		printerr("Invalid file type, expression list file must be a .txt file")
		return
	
	file.open(file_path, file.READ)
	
	clear()
	var next_line = ""
	while !file.eof_reached():
		next_line = file.get_line()
		if next_line.length() > 0:
			add_item(next_line)
