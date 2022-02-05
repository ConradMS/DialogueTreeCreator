extends PopupMenu

var recentSearches : PoolStringArray
const MAX_RECENTS = 5
const RECENTS = "Recents"

onready var recents = $Recents

func _ready():
	add_submenu_item("Recents", RECENTS, 0)
	

func _build_recents(recent_searches : PoolStringArray):
		recents.clear()
		for index in recent_searches.size():
			recents.add_item(recent_searches[index], index)
