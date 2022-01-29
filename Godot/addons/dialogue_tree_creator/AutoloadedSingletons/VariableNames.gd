extends Node

const NODE_TYPES = {
	DIALOGUE_NODE = "Dialogue",
	DYNAMIC_NODE = "Dynamic",
	CHOICE_NODE = "Choice"
}

const TREE_NODE_VARS : Dictionary = {
	ID = "id",
	LINKS = "links",
	TYPE = "type"
}

const DIALOGUE_NODE_VARS : Dictionary = {
	LINES = "lines",
	CHARACTER = "char_name",
	EXPRESSION = "expression",
}

const DYANIMC_NODE_VARS : Dictionary = {
	SCRIPTS = "scritps",
	THEME = "theme"
}

const CHOICE_NODE_VARS : Dictionary = {
	CHOICE_HINT = "choice hint"
}

const LINK_VARS : Dictionary = {
	LINKED_ID = "linked_id",
	PRIORITY = "priority",
	CONDITIONS = "conditions"
}

const CHOICE_LINK_VARS : Dictionary = {
	CHOICE_TEXT = "choice_text"
}
