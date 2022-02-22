extends Control
class_name Link


var linked_id : int = -1
var priority : int
var conditions : PoolStringArray

var id : int

onready var priorityBox : SpinBox = $SpinBox
onready var selectorRoot = $ConditionSelectorRoot
onready var condition_box_scene = preload("res://addons/dialogue_tree_creator/EditorGUI/DialogueTreeEditor/Links/PopupConditionList.tscn")

signal remove_link(id)
signal change_priority(old, new, link)

func init(id_i : int):
	id = id_i

func _ready():
	selectorRoot.connect("selection_made", self, "_update_conditions")


func build_from_var_dict(var_dict : Dictionary) -> bool:
	var ok = true
	var required_keys = DialogueTreeVariableNames.LINK_VARS.values()
	
	if(!var_dict.has_all(required_keys)):
		printerr("Link does not contain all of the required link varaibles")
		ok = false
		return ok
	
	var pri = var_dict[DialogueTreeVariableNames.LINK_VARS.PRIORITY]
	var link_id = var_dict[DialogueTreeVariableNames.LINK_VARS.LINKED_ID]
	var id_in = var_dict[DialogueTreeVariableNames.LINK_VARS.ID]
	var cond = var_dict[DialogueTreeVariableNames.LINK_VARS.CONDITIONS]
	
	pri = int(pri) if pri is float else pri
	link_id = int(link_id) if link_id is float else link_id
	id_in = int(id_in) if id_in is float else id_in
	
	if !(pri is int and cond is Array and link_id is int):
		printerr("Link varaibles are not the required type")
		ok = false
		
	priority = pri
	linked_id = link_id
	conditions = cond
	id = id_in
	
	return ok


func add_condition(potential_new_condition : String):
	var has_condition = false
	var boxes = selectorRoot.condition_boxes.values()
	for box in boxes:
		if !(box is ConditionBox):
			printerr("All boxes in selector root should be condition boxes")
			return
		
		var list = box.conditionList
		
		if (list is ItemList):
			for i in range(0, list.get_item_count()):
				if list.get_item_text(i) == potential_new_condition:
					has_condition = true
		else:
			printerr("Condition list should always be item list")
			return
	
	if !(has_condition):
		var imports_box : ConditionBox = selectorRoot.get_imports_submenu()
		
		if imports_box == null:
			imports_box = condition_box_scene.instance()
			imports_box.name = selectorRoot.IMPORTS_BOX_NAME
			selectorRoot.add_external_condition_box(imports_box.name, imports_box)
		
		var item_list = imports_box.conditionList
		if item_list is ItemList:
			item_list.add_item(potential_new_condition)
		else:
			printerr("Condition list is not node type itemlist")
			return


func sync_link():
	select_conditions(conditions)
	priorityBox.value = priority
	

func select_conditions(cond : Array):
	for condition_box in selectorRoot.condition_boxes.values():
		if !(condition_box is ConditionBox):
			printerr("Condition Box not type conditionBox")
			return
		
		var item_list : ItemList = condition_box.conditionList
		
		for id in item_list.get_item_count():
			var item_text = item_list.get_item_text(id)
			if item_text in cond:
				item_list.select(id)
				cond.remove(item_text)


func _on_RemoveLink_pressed():
	emit_signal("remove_link", id)
	

func set_priority(priority_val : int):
	priority = priority_val
	priorityBox.value = priority_val
	

func _on_SpinBox_value_changed(value):
	if priority != value:
		emit_signal("change_priority", priority, value, self)


func is_in_priorty_range(value : int):
	return value >= priorityBox.min_value and value <= priorityBox.max_value


func _on_ConditionList_multi_selected(index, selected):
	print(index, " ", selected)


func _update_conditions():
	conditions = selectorRoot.get_selected()


func build_conditions_list(path):
	selectorRoot.build_conditions(path)


func get_var_dict() -> Dictionary:
	var vars : Dictionary = {}
	vars[DialogueTreeVariableNames.LINK_VARS.ID] = id
	vars[DialogueTreeVariableNames.LINK_VARS.LINKED_ID] = linked_id
	vars[DialogueTreeVariableNames.LINK_VARS.PRIORITY] = priority
	vars[DialogueTreeVariableNames.LINK_VARS.CONDITIONS] = conditions
	return vars
	

