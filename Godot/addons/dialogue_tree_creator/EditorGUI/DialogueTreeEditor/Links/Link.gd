extends Control
class_name Link


var linked_id : int
var priority : int
var conditions : PoolStringArray

var id : int

onready var priorityBox : SpinBox = $SpinBox
onready var conditionsList : ItemList = $PopupConditionList/ConditionList

signal remove_link(id)
signal change_priority(old, new, link)

func init(id_i : int):
	id = id_i

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


func _on_ConditionList_focus_exited():
	var selectedItem : PoolIntArray = conditionsList.get_selected_items()
	conditions.empty()
	for item in selectedItem:
		var condition : String = conditionsList.get_item_text(item)
		conditions.append(condition)


func get_var_dict() -> Dictionary:
	var vars : Dictionary = {}
	vars[DialogueTreeVariableNames.LINK_VARS.LINKED_ID] = linked_id
	vars[DialogueTreeVariableNames.LINK_VARS.PRIORITY] = priority
	vars[DialogueTreeVariableNames.LINK_VARS.CONDITIONS] = conditions
	return vars


func toJSON() -> String:
	var vars : Dictionary = {}
	vars[DialogueTreeVariableNames.LINK_VARS.LINKED_ID] = linked_id
	vars[DialogueTreeVariableNames.LINK_VARS.PRIORITY] = priority
	vars[DialogueTreeVariableNames.LINK_VARS.CONDITIONS] = conditions
	return to_json(vars)
