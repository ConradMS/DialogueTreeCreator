extends Control
class_name NodeScriptParam


var value
var value_as_string : String 
var info_text : String = "No info"

const types = {
	TYPE_INT = "int"
}

func set_info(var_name : String, var_type : String):
	pass


func init(type : int):
	call("init_" + types[type])

func init_int():
	var spinbox = SpinBox.new()
	# keep going 

# Type int 
func init_2():
	pass
