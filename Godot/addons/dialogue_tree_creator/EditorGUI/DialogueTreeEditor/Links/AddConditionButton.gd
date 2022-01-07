extends TextureButton

onready var conditionLine = $AddConditionLine

func _on_AddConditionButton_pressed():
	conditionLine.visible = true
	conditionLine.grab_focus()
