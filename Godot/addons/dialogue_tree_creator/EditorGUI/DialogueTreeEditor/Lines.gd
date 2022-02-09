extends TextEdit

const DEFAULT_TEXT = "Lines"
const FONT_COLOUR = "custom_colors/font_color"

const LIGHT_GRAY = Color(0.5, 0.5, 0.5, 1)
const WHITE = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	text = DEFAULT_TEXT
	set(FONT_COLOUR, LIGHT_GRAY)


func set_text(new_text : String):
	set(FONT_COLOUR, WHITE)
	text = new_text


func _on_Lines_focus_entered():
	if text == DEFAULT_TEXT:
		text = ""
		set(FONT_COLOUR, WHITE)


func _on_Lines_focus_exited():
	if text == "":
		text = DEFAULT_TEXT
		set(FONT_COLOUR, LIGHT_GRAY)
