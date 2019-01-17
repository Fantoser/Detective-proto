extends Node

export (PackedScene) var Thebutt

var leText = []
var listbutts = []
var activeButton = null
var line = 1
var listscript = preload("res://GUI/Listbutt.gd")
var wordscript = preload("res://GUI/Wordbutt.gd")
#onready var rowBox = $VBox/HBox


#	Items
var small = ["used", "gave", "picked up", "placed", "replaced", "hid", "thrown"]
var medium = ["used", "gave", "picked up", "placed", "replaced"]
var food = ["ate"]
var cloth = ["put on"]

#   Weapons
var firearm = ["fired", "reloaded", "emptied"]
var blunt = ["swinged", "hit", "thrown", "dodged with"]
var pointing = ["stabbed with", "thrown", "dodged with"]
var cutting = ["cut with", "cut trough with", "dodged with"]

#   Places
var room = ["went to", "left", "hid in"]
var hallway = ["went to", "left", "hid in", "went trough"]
var hiding = ["hid in", "put in", "came out of"]

#   Person
var person = ["saw", "talked with", "called"]

var afterwords = {
    thrown = "at",
    change = "with",
    used = "on",
    replaced = "with",
    gave = "to",
    hid = "in",
    placed = ["on", "in", "next to"],
}

var buttons = [
["Jack Hammer", [person] ],
["samurai spear", [medium, pointing] ],
["samurai costume", [medium, cloth] ],
["back of studio", [room] ]
]

var dicbutt = [
{word = "Jack Hammer", attributes = [person]},
{word = "samurai spear", attributes = [medium, pointing]},
{word = "samurai costume", attributes = [medium, cloth]},
{word = "plate", attributes = [small]},
{word = "Sal Manella", attributes =[person]},
{word = "back of studio", attributes = [room]},
]

func _ready():
	
	for butt in dicbutt:
		var cluebutt = Thebutt.instance()
		$Layer_1.add_child(cluebutt)
		
		cluebutt.text = butt["word"]
		cluebutt.type = "cluebutt"
		
		for item in butt["attributes"]:
			cluebutt.list += item
		
		cluebutt.rect_position = $ButtonPos.get_position()
		$ButtonPos.position += Vector2(cluebutt.rect_size[0] + 10, 0)

func _process(delta):
	pass

func _input(event):
   # Mouse in viewport coordinates
	if event is InputEventMouseButton:
		pass
#       print("Mouse Click/Unclick at: ", event.position)


func _add_text(new_word, pos=leText.size()):
	
	
	if leText.size() > 0:
		if leText[pos-1]["type"] != "afterword":
#			leText.insert(pos, ["list", "", $FollowButt.list])
			leText.insert(pos, {type = "list", word = "", list = $FollowButt.list})
			pos += 1
	
	leText.insert(pos, {type = "word", word = new_word, list = $FollowButt.list})
	
	_draw_text()

func _remove_text(ID):
	
	if leText[ID-1]["type"] == "afterword":
		if ID+1 < leText.size():
			if leText[ID+1]["type"] == "list":
				leText.remove(ID+1)
	
	if ID+1 < leText.size():
		if leText[ID+1]["type"] == "afterword":
			if ID+2 < leText.size():
				if leText[ID+2]["type"] == "word":
					leText.insert(ID+2, {type = "list", word = "", list = leText[ID+2]["list"]})
			leText.remove(ID+1)

	leText.remove(ID)
	
	if ID-1 > 0:
		if leText[ID-1]["type"] == "list":
			leText.remove(ID-1)
			
	_draw_text()
	
func _draw_text():

	
	listbutts = []
	var ID = 1
	
	# KILL (ALMOST) ALL THE CHILD OF LABELBUCKET
	for child in $labelBucket.get_children():
		if child.name != "LabelPos" and child.name != "wordlist":
			child.queue_free()

	$labelBucket/LabelPos.position[0] = 23.755379
	
	print("===============")
	
	for i in range(0, leText.size()):
		
		print(leText[i]["type"] + "   " + leText[i]["word"])
		
	# INSERT LISTBUTTONS
		if leText[i]["type"] == "list":
			var listbutt = Thebutt.instance()
			var newListButt = Label.new()
			newListButt.rect_size = Vector2(0, 10)
			newListButt.set_script(listscript)
			listbutts.append(newListButt)
			newListButt.ID = i
			newListButt.type = "listbutt"
			newListButt.list = leText[i]["list"]
			
		# CHANGE TEXT ON LISTBUTTONS
			if leText[i]["word"] != "":
				newListButt.text = leText[i]["word"]
			else:
				newListButt.text = "SELECT"
				
			$labelBucket.add_child(newListButt)
				
			_position(newListButt)

		if leText[i]["type"] == "word":
		# INSERT "THE" BEFORE WORDS
			if i != 0 and leText[i]["list"] != person:
				var theLabel = Label.new()
				theLabel.text = "the"
				
				$labelBucket.add_child(theLabel)
				_position(theLabel)

		# INSERT WORDS
			var wordLabel = Label.new()
			wordLabel.text = leText[i]["word"]
			wordLabel.set_script(wordscript)
			wordLabel.ID = i
			
			$labelBucket.add_child(wordLabel)
			_position(wordLabel)
			
	# INSERT COMMA
		if i != 0 and leText[i-1]["type"] == "list":
			if afterwords.has(leText[i-1]["word"]) == false and leText[i-1]["word"] != "":
				if i+1 < leText.size():
					if leText[i+1]["type"] == "list":
						var commaLabel = Label.new()
						commaLabel.text = ","
						$labelBucket.add_child(commaLabel)
						$labelBucket/LabelPos.position[0] -= 8
						_position(commaLabel)
			

	# INSERT AFTERWORDS
		if leText[i]["type"] == "afterword":
			var afterLabel = Label.new()
			afterLabel.text = leText[i]["word"]
			
			$labelBucket.add_child(afterLabel)
			_position(afterLabel)
			
	print("===============")

func _position(node):
	node.rect_position = $labelBucket/LabelPos.position
	$labelBucket/LabelPos.position[0] += node.rect_size[0] + 8

func _on_wordlist_item_selected(index):
	
# CHANGE BUTTON TEXT
	for butt in listbutts:
		if butt.ID == activeButton:
			leText[butt.ID]["word"] = $labelBucket/wordlist.get_item_text(index)


# HANDLE AFTERWORD AND NEXT LIST/AFTERWORD
	if activeButton+2 < leText.size():
		if afterwords.has($labelBucket/wordlist.get_item_text(index)):
				if leText[activeButton+2]["type"] == "afterword":
					leText[activeButton+2]["word"] = str(afterwords[$labelBucket/wordlist.get_item_text(index)])
				else:
					if leText[activeButton+2]["type"] == "list":
						if activeButton+4 < leText.size():
							if leText[activeButton+4]["type"] == "afterword":
								leText.remove(activeButton+4)
						leText.remove(activeButton+2)
					leText.insert(activeButton+2, {type = "afterword", word = str(afterwords[$labelBucket/wordlist.get_item_text(index)])})
		else:
			if leText[activeButton+2]["type"] == "afterword":
				leText.remove(activeButton+2)
				if leText[activeButton+2]["type"] == "word":
					leText.insert(activeButton+2, {type = "list", word = "", list = leText[activeButton+2]["list"]})
	else:
		if afterwords.has($labelBucket/wordlist.get_item_text(index)):
			leText	.insert(activeButton+2, {type = "afterword", word = str(afterwords[$labelBucket/wordlist.get_item_text(index)])})

# PUT BACK LIST
	$labelBucket/wordlist.rect_position = Vector2(-2000, -2000)
		
	_draw_text()
