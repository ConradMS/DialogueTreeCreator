extends TextEdit

const DEFAULT_TEXT : String = "Choice hint"
const FONT_COLOUR = "custom_colors/font_color"

const LIGHT_GRAY = Color(0.5, 0.5, 0.5, 1)
const WHITE = Color(1, 1, 1, 1)

func _ready():
	text = DEFAULT_TEXT
	set(FONT_COLOUR, LIGHT_GRAY)

func _on_TextEdit_focus_entered():
	if text == DEFAULT_TEXT:
		text = ""
	set(FONT_COLOUR, WHITE)


func _on_TextEdit_focus_exited():
	if text == "":
		text = DEFAULT_TEXT
		set(FONT_COLOUR, LIGHT_GRAY)
