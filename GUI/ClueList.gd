extends Control

onready var gui = get_parent()
onready var list = get_node("ItemList")
onready var desc = get_node("DescLabel")

var active = false

func _makelist():
	
	list.clear()
	
	for id in gui.cluelist:
		list.add_item(gui.cluelist[id]["word"])

func _on_ItemList_item_selected(index):
	var selected
	
	for id in gui.cluelist:
		if gui.cluelist[id]["word"] == list.get_item_text(index):
			selected = id
	
	desc.set_bbcode(gui.cluelist[selected]["description"].c_unescape())
	
	for tab in $LogContainer.get_children():
		if gui.cluelist[selected]["log"].has(tab.name):
			tab.get_child(0).set_bbcode(gui.cluelist[selected]["log"][tab.name].c_unescape())
		else:
			tab.get_child(0).set_bbcode("")


func _on_Cluelist_visibility_changed():
	desc.set_bbcode("")
