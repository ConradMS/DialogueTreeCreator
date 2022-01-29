extends ConfirmationDialog

var methods : Array = []
var selected_method : Dictionary = {}
onready var matches = $VBoxContainer/Matches
onready var description_box = $VBoxContainer/Description
onready var search_bar = $VBoxContainer/SearchBar
const NOT_FOUND = -1

signal method_selected(method)
# Search will return first method header that contains the given substring 

const method_parts = {
	DESCRIPTION = "description",
	HEADER = "header",
	ARGS = "args",
	RETURN_TYPE = "return_type",
	NAME = "name"
}

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed:
			if matches.get_selected_items().size() == 1:
				select_index(matches.get_selected_items()[0])


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
	select_index(index)


func _on_SearchBar_text_changed(new_text):
	if new_text == "":
		matches.unselect_all()
	
	var matches_index = []
	for i in range(0, methods.size()):
		if methods[i][method_parts.NAME].find(new_text) != NOT_FOUND:
			matches_index.append(i)
	
	if matches_index.size() > 0:
		var min_size = matches_index[0]
		
		for i in range(0, matches_index.size()):
			if methods[matches_index[i]][method_parts.NAME].length() < methods[min_size][method_parts.NAME].length():
				min_size = matches_index[i]
		
		matches.select(min_size)
		matches.emit_signal("item_selected", min_size)
	else:
		pass
		# This will be a setting you can enable
#		matches.unselect_all()


func _on_MethodSelector_visibility_changed():
	search_bar.call_deferred("grab_focus")


func _on_MethodSelector_confirmed():
	if matches.get_selected_items().size() == 0:
		# Have this be like a warning popup when that is implemented
		print("You have no selected node script")
		return
		
	if matches.get_selected_items().size() == 1:
		select_index(matches.get_selected_items()[0])
	else:
		printerr("Only one Node script per config can be selected")
		return


func select_index(index : int):
	if visible:
		selected_method = methods[index]
		emit_signal("method_selected", selected_method)
		hide()


func get_method_by_name(method_name : String) -> Dictionary:
	for method in methods:
		if method[method_parts.NAME] == method_name:
			return method
	
	printerr("No method found: ", method_name)
	return {}
