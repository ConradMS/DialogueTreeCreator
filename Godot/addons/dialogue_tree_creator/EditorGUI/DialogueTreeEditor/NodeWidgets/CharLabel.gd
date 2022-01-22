extends TextEdit

signal add_recent(recent)
const DEFAULT_TEXT = "Character Name"
const FONT_COLOUR = "custom_colors/font_color"

const LIGHT_GRAY = Color(0.5, 0.5, 0.5, 1)
const WHITE = Color(1, 1, 1, 1)

func _ready():
	text = DEFAULT_TEXT
	set(FONT_COLOUR, LIGHT_GRAY)

func _input(event):
	# Stop editing text field if currently editing text field and you press enter
	if has_focus():
		if Input.is_key_pressed(KEY_ENTER):
			emit_signal("add_recent", text)
			release_focus()


func _on_CharLabel_focus_entered():
	if text == DEFAULT_TEXT:
		set(FONT_COLOUR, WHITE)
		text = ""


func _on_CharLabel_focus_exited():
	if text == "":
		set(FONT_COLOUR, LIGHT_GRAY)
		text = DEFAULT_TEXT
		

func change_text_from_suggestions(text_i : String):
	text = text_i
	emit_signal("text_changed")
	emit_signal("add_recent", text_i)
	set(FONT_COLOUR, WHITE)
