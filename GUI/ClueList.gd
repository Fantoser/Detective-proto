extends Control

onready var gui = get_parent()
onready var list = get_node("ItemList")
onready var desc = get_node("DescLabel")

var active = false

func _makelist():
	
	list.clear()
	
	for item in gui.cluelist.keys():
		list.add_item(item)

func _on_ItemList_item_selected(index):
	var selected = list.get_item_text(index)
	
	desc.set_bbcode(gui.cluelist[selected].c_unescape())
