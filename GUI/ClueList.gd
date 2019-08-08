extends Control

onready var gui = get_parent()
onready var list = get_node("ItemList")
onready var desc = get_node("DescLabel")

var active = false

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if list.is_anything_selected():
		_changedesc()

func _makelist():
	
	list.clear()
	
	for item in gui.cluelist.keys():
		list.add_item(item)

func _changedesc():
	var selected = list.get_item_text(list.get_selected_items()[0])
	desc.text = gui.cluelist[selected]