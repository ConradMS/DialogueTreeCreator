extends GraphNode


onready var dialogueLinesBox = $Lines
const MIN_NODE_OPTIONS_SIZE = Vector2(50, 50)

# Fraction of the node the textbox takes up
const TEXTBOX_FRAC = 0.6

func _ready():
	var status = connect("resize_request", self, "_resize")
	if status != OK:
		printerr("DialogueGraphNode Line 9, Error: ", status)
	
#	call_deferred("_resize")

func _calculate_anchor_size():
	pass

func _resize(new_size = Vector2(0, 0)):
	var min_size = MIN_NODE_OPTIONS_SIZE + (dialogueLinesBox.MIN_SIZE) / TEXTBOX_FRAC
	var rescale_size = min_size
	if _bigger_components(min_size, new_size):
		rescale_size = new_size
	rect_size = rescale_size

	# This fixes flickering for some reason
#	call_deferred("_resize_textbox", rescale_size)


func _bigger_components(a : Vector2, b : Vector2) -> bool:
	return b.x > a.x and b.y > a.y


func _resize_textbox(new_size : Vector2):
	var textbox_size = (new_size - MIN_NODE_OPTIONS_SIZE) * TEXTBOX_FRAC
	var rescale_size = dialogueLinesBox.MIN_SIZE
	if _bigger_components(dialogueLinesBox.MIN_SIZE, textbox_size):
		rescale_size = textbox_size

	dialogueLinesBox.rect_size.y = rescale_size.y
