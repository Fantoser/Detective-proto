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
	
	desc.set_bbcode(gui.cluelist[selected]["description"].c_unescape())
	
	for tab in $TabContainer.get_children():
		if gui.cluelist[selected]["log"].has(tab.name):
			$"TabContainer/Julia Fang/Log".set_bbcode(gui.cluelist[selected]["log"][tab.name].c_unescape())


func _on_Cluelist_visibility_changed():
	desc.set_bbcode("")
