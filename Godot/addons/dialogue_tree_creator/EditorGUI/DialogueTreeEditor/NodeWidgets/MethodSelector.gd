extends ConfirmationDialog

var methods : Array = []
onready var matches = $VBoxContainer/Matches
onready var description_box = $VBoxContainer/Description

# Search will return first method header that contains the given substring 

const method_parts = {
	DESCRIPTION = "description",
	HEADER = "header",
	ARGS = "args",
	RETURN_TYPE = "return_type" 
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_methods(methods_i):
	set_methods(methods_i)
	build_matches()


func set_methods(methods_i : Array):
	methods = methods_i


func build_matches():
	matches.clear()
	for method in methods:
		matches.add_item(method[method_parts.HEADER])


func _on_Matches_item_selected(index):
	description_box.text = methods[index][method_parts.DESCRIPTION]


func _on_Matches_item_activated(index):
	pass # Replace with function body.
