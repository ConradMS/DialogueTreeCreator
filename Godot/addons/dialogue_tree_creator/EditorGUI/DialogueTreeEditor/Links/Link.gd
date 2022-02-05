extends Control
class_name Link


var linked_id : int
var priority : int
var conditions : PoolStringArray

var id : int

onready var priorityBox : SpinBox = $SpinBox
onready var selectorRoot = $ConditionSelectorRoot

signal remove_link(id)
signal change_priority(old, new, link)

func init(id_i : int):
	id = id_i

func _ready():
	selectorRoot.connect("selection_made", self, "_update_conditions")

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
