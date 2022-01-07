extends Node


var nodes : Dictionary = {}
var recentSearches : PoolStringArray
const MAX_RECENTS = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_recent(recent : String):
	recentSearches.insert(0, recent)
	if recentSearches.size() > MAX_RECENTS:
		recentSearches.remove(recentSearches.size() - 1)
