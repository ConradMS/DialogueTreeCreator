extends TextEdit

const DEFAULT_SIZE = 26
const MAX_EXPAND = 3
const SCROLL_BAR_WIDTH = 10

func _on_ChoiceLinkText_text_changed():
	var font = get_font("font")
	var size = font.get_string_size(text)
	var textbox_size = rect_size
	
	textbox_size.x -= SCROLL_BAR_WIDTH
	rect_min_size.y = DEFAULT_SIZE * min((int(size.x) / int(textbox_size.x) + 1), MAX_EXPAND)
