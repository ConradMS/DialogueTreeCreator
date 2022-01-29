extends HBoxContainer

func _ready():
	rect_size = get_minimum_size()

func get_adj_min_size():
	var min_height = Vector2(0, 0)
	for child in self.get_children():
		if child is Control:
			if child.rect_size.y > min_height.y:
				min_height.y = child.rect_size.y
			child.rect_min_size = Vector2(0, rect_size.y)
	return Vector2(rect_size.x, min_height.y)
