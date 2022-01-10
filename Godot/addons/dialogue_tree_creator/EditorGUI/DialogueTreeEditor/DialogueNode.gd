extends Control
class_name DialogueNode

onready var popupMenu = $DialogueGraphNode/CharacterSearchBar/PopupButton/PopupMenu

var title : String = "Dialogue Node, ID : "

var id : int
var expr : String 
var char_name : String


# Called when the node enters the scene tree for the first time.
func _ready():
	if id == null:
		printerr("Dialogue Node's id should never be null")
		title += "null"
	else:
		title += String(id)

func update_recent_char_searches(searches : PoolStringArray):
	popupMenu._build_recents(searches)
