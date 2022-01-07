extends Control


onready var conditionList = $ConditionList
onready var conditionAdder = $AddConditionButton/AddConditionLine
onready var conditionButton = $AddConditionButton

func _ready():
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


func _on_PopupConditionList_pressed():
	conditionList.visible = true
	conditionList.grab_focus()


func _on_ConditionList_visibility_changed():
	conditionButton.visible = conditionList.visible
