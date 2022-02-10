extends Control
class_name Link


var linked_id : int
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
		printerr("Link does not contain all of the required link varaaibles")
		ok = false
		return ok
	
	var pri = var_dict[DialogueTreeVariableNames.LINK_VARS.PRIORITY]
	var link_id = var_dict[DialogueTreeVariableNames.LINK_VARS.LINKED_ID]
	
	var cond = var_dict[DialogueTreeVariableNames.LINK_VARS.CONDITIONS]
	
	pri = int(pri) if pri is float else pri
	link_id = int(link_id) if link_id is float else link_id
	
	if !(pri is int and cond is Array and link_id is int):
		printerr("Link varaibles are not the required type")
		ok = false
		
	priority = pri
	linked_id = link_id
	cond = conditions
	
	return ok


func sync_link():
#	select_conditions(conditions)
	priorityBox.value = priority
	

func select_conditions(cond : Array):
	for condition_list in selectorRoot.condition_boxes.values():
		var item_list : ItemList = condition_list
		
		for id in item_list.get_item_count():
			var item_text = item_list.get_item_text(id)
			if item_text in cond:
				item_list.select(id)
				cond.remove(item_text)
				
	if !(cond.empty()):
		var condition_box : ConditionBox = condition_box_scene.instance()
		for condition in cond:
			if condition is String:
				condition_box.add_new_condition(condition)
				selectorRoot.add_external_condition_box("Imported Conditions", condition_box)
	

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
	vars[DialogueTreeVariableNames.LINK_VARS.LINKED_ID] = linked_id
	vars[DialogueTreeVariableNames.LINK_VARS.PRIORITY] = priority
	vars[DialogueTreeVariableNames.LINK_VARS.CONDITIONS] = conditions
	return vars
	

