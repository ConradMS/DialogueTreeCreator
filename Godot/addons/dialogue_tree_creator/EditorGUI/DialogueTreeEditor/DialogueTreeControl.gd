extends Control

onready var addNodeMenu = $VSplitContainer/OptionsBar/AddnodeMenu
onready var dialogueTree = $VSplitContainer/DialogueTree

# Called when the node enters the scene tree for the first time.
func _ready():
	var addNodePopup : PopupMenu = addNodeMenu.get_popup()
	addNodePopup.connect("index_pressed", self, "_add_node")

func _add_node(type : int):
	dialogueTree.add_node(type)


func _input(event):
	pass
