extends Node

export (PackedScene) var Thebutt
export (PackedScene) var Insertspace

var leText = []
var leQuestions = {}
var qid:int = 0
var listbutts = []
var activeButton = null
#var line = 1
var clue_selected = 0
var desc = ""
var listscript = preload("res://GUI/Thought system/Listbutt.gd")
var wordscript = preload("res://GUI/Thought system/Wordbutt.gd")
onready var progress = PROGRESS


#	Items
#warning-ignore:unused_class_variable
var small = ["used", "gave", "picked up", "placed", "replaced", "hid", "thrown"]
#warning-ignore:unused_class_variable
var medium = ["used", "gave", "picked up", "placed", "replaced", "throwed away"]
#warning-ignore:unused_class_variable
var food = ["ate"]
#warning-ignore:unused_class_variable
var cloth = ["put on"]

#   Weapons
#warning-ignore:unused_class_variable
var firearm = ["fired", "reloaded", "emptied"]
#warning-ignore:unused_class_variable
var blunt = ["swinged", "hit", "thrown", "dodged with"]
#warning-ignore:unused_class_variable
var pointing = ["stabbed with", "thrown", "dodged with"]
#warning-ignore:unused_class_variable
var cutting = ["cut with", "cut trough with", "dodged with"]

#   Places
#warning-ignore:unused_class_variable
var room = ["went to", "left", "hid in"]
#warning-ignore:unused_class_variable
var hallway = ["went to", "left", "hid in", "went trough"]
#warning-ignore:unused_class_variable
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

var Categories ={ 
	#	Items
	small = ["used", "gave", "picked up", "placed", "replaced", "hid", "thrown"],
	medium = ["used", "gave", "picked up", "placed", "replaced", "throwed away"],
	food = ["ate"],
	cloth = ["put on"],
	
	#   Weapons
	firearm = ["fired", "reloaded", "emptied"],
	blunt = ["swinged", "hit", "thrown", "dodged with"],
	pointing = ["stabbed with", "thrown", "dodged with"],
	cutting = ["cut with", "cut trough with", "dodged with"],
	
	#   Places
	room = ["went to", "left", "hid in"],
	hallway = ["went to", "left", "hid in", "went trough"],
	hiding = ["hid in", "put in", "came out of"],
	
	#   Person
	person = ["saw", "talked with", "called"],
	
	# Question
	where = ["when", "at"],
	how = ["heard", "saw", "went to", "was in"],
	why = ["heard", "saw", "went to", "was in"],
	when = ["heard", "saw", "went to", "was in"],
	
	afterwords = {
		thrown = "at",
		change = "with",
		used = "on",
		replaced = "with",
		gave = "to",
		hid = "in",
		placed = ["on", "in", "next to"],
	}
}

#warning-ignore:unused_class_variable
var buttons = [
["Jack Hammer", [person] ],
["samurai spear", [medium, pointing] ],
["samurai costume", [medium, cloth] ],
["back of studio", [room] ]
]
#
var dicbutt = [
{word = "Jack Hammer", attributes = [person], desc = "The superstar"},
{word = "samurai spear", attributes = [medium, pointing], desc = "The murder weapon"},
{word = "samurai costume", attributes = [medium, cloth], desc = "Found in the trash"},
{word = "plate", attributes = [small], desc = "A cheap plastic plate"},
{word = "Sal Manella", attributes =[person], desc = "A nerd"},
{word = "knife", attributes = [small, pointing, cutting], desc = "A knife stained with barbecue sauce"},
{word = "living room", attributes = [room], desc = "The living room, where someone dieded. The irony."},
]

func _ready():
	$Submit.connect("pressed", self, "_submit")

	for butt in dicbutt:
		var cluebutt = Thebutt.instance()
		$buttBucket.add_child(cluebutt)

		cluebutt.text = butt.word
		cluebutt.enabled_focus_mode = false

		cluebutt.desc = progress.desc
		for item in butt["attributes"]:
			cluebutt.list += item

		cluebutt.rect_position = $buttBucket/ButtonPos.get_position()
		$buttBucket/ButtonPos.position += Vector2(cluebutt.rect_size[0] + 10, 0)

func _setup(id):
	qid = id
	$QuestionLabel.text = leQuestions[qid]["question"]
	leText = []
	for question in leQuestions[qid]["answer"]:
		leText.append(question)
	$CurrentLabel.text = leQuestions[qid]["raw_answer"]
	_draw_text()

func _submit():
	leQuestions[qid]["answer"] = []
	leQuestions[qid]["raw_answer"] = ""
	
	for answer in leText:
		leQuestions[qid]["answer"].append(answer)

	for child in $labelBucket.get_children():
		if child.name != "LabelPos" and child.name != "wordlist" and child.get_class() != "TextureButton":
			if child.text != ",":
				leQuestions[qid]["raw_answer"] += " "
				
			leQuestions[qid]["raw_answer"] += child.text
	leQuestions[qid]["raw_answer"] = leQuestions[qid]["raw_answer"].substr(1, leQuestions[qid]["raw_answer"].length())
	$CurrentLabel.text = leQuestions[qid]["raw_answer"]


func _process(delta):
	if clue_selected == 2:
		clue_selected = 0
	if Input.is_action_just_pressed("mouse_left"):
		if clue_selected == 1:
			clue_selected = 2
	$DescLabel.text = progress.desc

func _input(event):
   # Mouse in viewport coordinates
	if event is InputEventMouseButton:
		pass

func _add_clue(list = null):

	var word = progress.variables["word"]
	var description = progress.variables["desc"]
	var attributes = progress.variables["atrbs"]
	progress.variables["word"] = ""
	progress.variables["desc"] = ""
	progress.variables["atrbs"] = ""

#Check if clue already obtained
	var doit = true
	for butt in $buttBucket.get_children():
		if butt.name != "ButtonPos":
			if butt.text == word:
				get_parent().cluelist[word] += description
				doit = false

#Adding clue
	if doit == true:

		get_parent().cluelist[word] = description

		var cluebutt = Thebutt.instance()
		$buttBucket.add_child(cluebutt)

		cluebutt.text = word
		cluebutt.enabled_focus_mode = false

		cluebutt.desc = description

		if attributes.size() > 0:
			for item in attributes.split(","):
				for category in Categories.keys():
					if str(category) == item:
						cluebutt.list += Categories[category]

		if $buttBucket/ButtonPos.position[0] + cluebutt.rect_size[0] > get_viewport().size[0] - 300:
			$buttBucket/ButtonPos.position[0] = 10.488
			$buttBucket/ButtonPos.position[1] += 40
		cluebutt.rect_position = $buttBucket/ButtonPos.get_position()
		$buttBucket/ButtonPos.position += Vector2(cluebutt.rect_size[0] + 10, 0)

func _add_text(new_word, new_list, pos=leText.size()):
	
	if pos != leText.size():
		if leText[pos]["type"] == "word":
			leText.insert(pos, {type = "list", word = "", list = leText[pos]["list"]})
	
	if leText.size() > 0:
		if leText[pos-1]["type"] != "afterword":
#			leText.insert(pos, ["list", "", $FollowButt.list])
			leText.insert(pos, {type = "list", word = "", list = new_list})
			pos += 1
	
	leText.insert(pos, {type = "word", word = new_word, list = new_list})

	
	_draw_text()

func _change_text(ID, newText, newList):
	if ID+1 < leText.size():
		if leText[ID+1]["type"] == "afterword":
			leText.remove(ID+1)
			if ID+1 < leText.size():
				if leText[ID+1]["type"] == "word":
					leText.insert(ID+1, {type = "list", word = "", list = leText[ID+1]["list"]})
	leText[ID]["word"] = newText
	leText[ID]["list"] = newList
	if leText[ID-1]["type"] == "list":
		leText[ID-1]["list"] = newList
		leText[ID-1]["word"] = ""
		
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
#	var ID = 1
	var ai = "null"
	
	# KILL (ALMOST) ALL THE CHILD OF LABELBUCKET
	for child in $labelBucket.get_children():
		if child.name != "LabelPos" and child.name != "wordlist":
			child.queue_free()

	$labelBucket/LabelPos.position[0] = 23.755379
	$labelBucket/LabelPos.position[1] = 15
	
	
	for i in range(0, leText.size()):
		
		
		if i < leText.size()-1:
			ai = leText[i+1]["type"]
		
	# INSERT LISTBUTTONS
		if leText[i]["type"] == "list":
#			var listbutt = Thebutt.instance()
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


	# INSERT AFTERWORDS OR AFTERLIST
		if leText[i]["type"] == "afterword":
			if leText[i].has("list"):
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
			else:
				var afterLabel = Label.new()
				afterLabel.text = str(leText[i]["word"])
	
				$labelBucket.add_child(afterLabel)
				_position(afterLabel)
			


	# INSERT INSERTSPACE
		if i < leText.size()-1:
			if leText[i]["type"] == "word" and ai != "afterword" or leText[i]["type"] == "afterword":
				var insertspace = Insertspace.instance()
				$labelBucket.add_child(insertspace)
				insertspace.ID = i+1
				_position(insertspace)
				
	# PUT WORDLIST AS FIRST CHILD
		$labelBucket/wordlist.raise()


func _position(node):
	if node is TextureButton:
		node.rect_position = $labelBucket/LabelPos.position - Vector2(10, 20)
	else:
		if $labelBucket/LabelPos.position[0] + node.rect_size[0] > get_viewport().size[0] - 200:
			$labelBucket/LabelPos.position[0] = 23.755
			$labelBucket/LabelPos.position[1] += 25
		node.rect_position = $labelBucket/LabelPos.position
		$labelBucket/LabelPos.position[0] += node.rect_size[0] + 8

func _on_wordlist_item_selected(index):
	
# CHANGE BUTTON TEXT
	for butt in listbutts:
		if butt.ID == activeButton:
			leText[butt.ID]["word"] = $labelBucket/wordlist.get_item_text(index)
			


# HANDLE AFTERWORD AND NEXT LIST/AFTERWORD
	var afterword = ""
	if afterwords.has($labelBucket/wordlist.get_item_text(index)):
		afterword = afterwords[$labelBucket/wordlist.get_item_text(index)]

	if activeButton+2 < leText.size():
		if afterwords.has($labelBucket/wordlist.get_item_text(index)):
				if leText[activeButton+2]["type"] == "afterword":
					if typeof(afterword) != 4:
						leText[activeButton+2]["word"] = ""
						leText[activeButton+2]["list"] = afterword
					else:
						leText[activeButton+2]["word"] = afterword
						leText[activeButton+2].erase("list")
						listbutts.erase(activeButton+2)
				else:
					if leText[activeButton+2]["type"] == "list":
						leText.remove(activeButton+2)
						if typeof(afterword) != 4:
							listbutts.erase(activeButton+2)
						if activeButton+4 < leText.size():
							if leText[activeButton+4]["type"] == "afterword":
								leText.remove(activeButton+4)
								if typeof(afterword) != 4:
									listbutts.erase(activeButton+4)
								if activeButton+5 < leText.size():
									if leText[activeButton+5]["type"] == "word":
										leText.insert(activeButton+5, {type = "list", word = "", list = leText[activeButton+5]["list"]})
					if typeof(afterword) == 4:
						leText.insert(activeButton+2, {type = "afterword", word = afterword})
					else:
						leText.insert(activeButton+2, {type = "afterword", word = "", list = afterword})
		else:
			if leText[activeButton+2]["type"] == "afterword":
				leText.remove(activeButton+2)
				if activeButton+2 < leText.size():
					if leText[activeButton+2]["type"] == "word":
						leText.insert(activeButton+2, {type = "list", word = "", list = leText[activeButton+2]["list"]})
	else:
		if afterwords.has($labelBucket/wordlist.get_item_text(index)):
			if typeof(afterword) == 4:
				leText.insert(activeButton+2, {type = "afterword", word = str(afterword)})
			else:
				leText.insert(activeButton+2, {type = "afterword", word = "", list = afterword})

# PUT BACK LIST
	$labelBucket/wordlist.rect_position = Vector2(-2000, -2000)
		
	_draw_text()

func _check_answer():
	pass
