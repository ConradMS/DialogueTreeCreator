extends OptionButton

func build_expression_list(file_path : String):
	var file = File.new()
	file.open(file_path, file.READ)
	
	var next_line = ""
	while !file.eof_reached():
		next_line = file.get_line()
		if next_line.length() > 0:
			add_item(next_line)
