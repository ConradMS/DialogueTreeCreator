extends PopupMenu

var recentSearches : PoolStringArray
const MAX_RECENTS = 5

onready var recents = $Recents

func _ready():
	add_submenu_item("Recents", "Recents", 0)

#func add_recent(recent : String):
#	recentSearches.insert(0, recent)
#	if recentSearches.size() > MAX_RECENTS:
#		recentSearches.remove(recentSearches.size() - 1)
#
#	_build_recents_popup()
#
#func _build_recents_popup():
#	recents.clear()
#	for index in recentSearches.size():
#		recents.add_item(recentSearches[index], index)
		

func _build_recents(recent_searches : PoolStringArray):
		recents.clear()
		for index in recent_searches.size():
			recents.add_item(recent_searches[index], index)
