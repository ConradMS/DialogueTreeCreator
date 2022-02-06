extends Control
class_name ConditionBox

onready var conditionList = $ConditionList
onready var conditionAdder = $AddConditionButton/AddConditionLine
onready var conditionButton = $AddConditionButton

func _ready():
	conditionList.visible = false
	var status = conditionAdder.connect("add_condition", conditionList, "_add_condition")
	if status != OK:
		printerr("ConditionList.gd, Line 9, Error: ", status)


func _process(_delta):
	if conditionList.visible == false:
		return
	
	if conditionList.has_focus() or conditionAdder.has_focus() or conditionButton.has_focus():
		conditionList.visible = true
	else:
		conditionList.visible = false


func _on_ConditionList_visibility_changed():
	conditionButton.visible = conditionList.visible


func show_box():
	conditionList.visible = true
	conditionList.call_deferred("grab_focus")


func add_new_condition(condition : String):
	conditionList.add_item(condition)
	
	
func get_conditions_list() -> ItemList:
	return conditionList
