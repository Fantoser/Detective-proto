extends Node

export (PackedScene) var Thebutt
export (PackedScene) var Insertspace

var font_Roboto = load("res://fonts/Roboto.tres")
var theme_default = load("res://assets/Themes/default.tres")
var wordstyle = load("res://assets/Themes/wordtheme.tres")

onready var cursor = $labelBucket/LabelPos

var cursor_starting_x = 7.54

var leText = []
var leQuestions = {}
var qid:int = -1
var listbutts = []
var activeButton = null
#var line = 1
var clue_selected = 0
var desc = ""
var listscript = preload("res://GUI/Thought system/Listbutt.gd")
var wordscript = preload("res://GUI/Thought system/Wordbutt.gd")
onready var progress = PROGRESS


#	Items

var small = ["used", "gave", "picked up", "placed", "replaced", "hid", "thrown"]

var medium = ["used", "gave", "picked up", "placed", "replaced", "throwed away"]

var large = ["used", "tipped over"]

var food = ["ate"]

var fabric = ["put on", "folded"]

#   Weapons

var firearm = ["fired", "reloaded", "emptied"]

var blunt = ["swinged", "hit", "thrown", "dodged with"]

var pointing = ["stabbed", "thrown", "dodged with"]

var cutting = ["cut with", "cut trough with", "dodged with"]

#   Places

var room = ["went into", "left", "hid in"]

var hallway = ["went to", "left", "hid in", "went trough"]

var hiding = ["hid in", "put in", "came out of"]

#   Person
var person = ["saw", "talked with", "called"]
var victim = ["saw", "talked with", "called", "ded"]

var afterwords = {
	thrown = "at",
	change = "with",
	used = "on",
	replaced = "with",
	gave = "to",
	hid = "in",
	placed = ["on", "in", "next to"],
	stabbed = "into",
	picked_up = "from"
}

var Categories ={ 
	#	Items
	small = ["used", "gave", "picked up", "placed", "replaced", "hid", "threw"],
	medium = ["used", "gave", "picked up", "placed", "replaced", "throwed away", "threw"],
	large = ["used", "tipped over"],
	food = ["ate"],
	cloth = ["put on"],
	fabric = ["put on", "folded"],
	
	#   Weapons
	firearm = ["fired", "reloaded", "emptied"],
	blunt = ["swinged", "hit with", "threw", "dodged with"],
	pointing = ["stabbed", "threw", "dodged with"],
	cutting = ["cut with", "cut trough with", "dodged with"],
	
	#   Places
	room = ["went into", "left", "hid in"],
	hallway = ["went to", "left", "hid in", "went trough"],
	hiding = ["hid in", "put in", "came out of"],
	
	#   Person
	person = ["saw", "talked with", "called"],
	impersonal = ["saw", "talked with", "called"],
	
	#   Question
	where = ["when", "at"],
	how = ["heard", "saw", "went to", "was in"],
	why = ["heard", "saw", "went to", "was in"],
	when = ["heard", "saw", "went to", "was in"],
	
	afterwords = {
		threw = "at",
		change = "with",
		used = "on",
		replaced = "with",
		gave = "to",
		hid = "in",
		placed = ["on", "in", "next to"],
		folded = ["around", "in half"],
		stabbed = "into",
		picked_up = "from",
		swinged = "at",
		hit_with = ""
	}
}

var dicbutt = [
{word = "kek_The culprit", attributes =["impersonal"], desc = "The person behind the murder"},
{word = "Eric Calvaire", attributes =["person"], desc = "The vicim"},
{word = "Lighthouse Candle", attributes = ["small"], desc = "A candle in the shape of a lighthouse."},
{word = "Sheppard's Lighter", attributes = ["small"], desc = "A lighter using a rope instead of fuel. Found on the ground."},
{word = "Gas Canister", attributes = ["medium", "blunt"], desc = "An iron casted empty gas canister found on the floor of the office. \n\nThere is a dent on the side."},
{word = "Ship Model", attributes = ["medium"], desc = "A pretty big ship model, found laying on the victim."},
{word = "Carpet", attributes = ["medium", "fabric"], desc = "A burned carpet the victim layed on.\n\nHave a strange burn mark."},
{word = "Long shelf", attributes = ["medium"], desc = "The longest shelf in the room"},
{word = "Knife", attributes = ["small", "cutting", "pointing"], desc = "Stabby stabby"}
]

func _ready():
	$Submit.connect("pressed", self, "_submit")

	for butt in dicbutt:
		var cluebutt = Thebutt.instance()
		$Grid/HBoxContainer.add_child(cluebutt)

		cluebutt.word = butt.word
		cluebutt.enabled_focus_mode = false
		cluebutt.rect_min_size.x = cluebutt.rect_min_size.x + 10

		cluebutt.desc = butt.desc
		for item in butt["attributes"]:
			if item == "person":
				cluebutt.person = true
			cluebutt.list += Categories[item]

#		cluebutt.rect_position = $buttBucket/ButtonPos.get_position()
#		$buttBucket/ButtonPos.position += Vector2(cluebutt.rect_size[0] + 10, 0)

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

	$DescLabel.set_bbcode(progress.desc.c_unescape())

	if Input.is_action_just_pressed("button3"):
		print(leText)

	if progress.variables["word"] != "":
		_add_clue()

	if progress.variables["evidenceQuestion"] != "":
		_add_assumed_evidence()

func _input(event):
   # Mouse in viewport coordinates
	if event is InputEventMouseButton:
		pass

func _add_clue(list = null):

	var word = progress.variables["word"]
	var description = progress.variables["desc"]
	var attributes = progress.variables["atrbs"]

#Check if clue already obtained
	var doit = true
	for butt in $Grid/HBoxContainer.get_children():
		if butt.name != "ButtonPos":
			if "_" in butt.word:
				if butt.word.split("_")[0] == word.split("_")[0]:
					doit = false
					get_parent().cluelist.erase(butt.word)
					butt.word = word
					butt.desc = description
					butt.list = []
					get_parent().cluelist[word] = {}
					get_parent().cluelist[word]["word"] = word.split("_")[1]
					get_parent().cluelist[word]["log"] = {}
					get_parent().cluelist[word]["description"] = description
					for item in attributes.split(","):
						for category in Categories.keys():
							if str(category) == item:
								if item == "person":
									butt.person = true
								butt.list += Categories[category]
					break
			if butt.word == word:
				doit = false
				get_parent().cluelist[word]["description"] += description

	progress.variables["word"] = ""
	progress.variables["desc"] = ""
	progress.variables["atrbs"] = ""

#Adding clue
	if doit == true:

		var textWord

		if "_" in word:
			textWord = word.split("_")[1]
		else:
			textWord = word

		get_parent().cluelist[word] = {}
		get_parent().cluelist[word]["word"] = textWord
		get_parent().cluelist[word]["log"] = {}
		get_parent().cluelist[word]["description"] = description



		var cluebutt = Thebutt.instance()
		$Grid/HBoxContainer.add_child(cluebutt)

		cluebutt.word = word
		cluebutt.enabled_focus_mode = false

		cluebutt.desc = description

		for item in attributes.split(","):
			for category in Categories.keys():
				if str(category) == item:
					if item == "person":
						cluebutt.person = true
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

func _add_assumed_evidence():
	pass

func _draw_text():

	
	listbutts = []
	var ai = "null"
	var textObject = ""
	var andHold = {}
	var commaCombo = false

	# KILL (ALMOST) ALL THE CHILD OF LABELBUCKET
	for child in $labelBucket.get_children():
		if child.name != "LabelPos" and child.name != "wordlist":
			child.queue_free()

	cursor.position[0] = cursor_starting_x
	cursor.position[1] = 15
	
	
	for i in range(0, leText.size()):

		if i < leText.size()-1:
			ai = leText[i+1]["type"]

	# INSERT LISTBUTTONS
		if leText[i]["type"] == "list":
			var newListButt = Label.new()
			newListButt.set("theme", theme_default)
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

		# INSERT "THE" BEFORE WORDS
		if leText[i]["type"] == "word":
			if !leText[i]["word"].begins_with("the") and leText[i]["list"] != person and leText[i]["word"] != textObject:
				var theLabel = Label.new()
				theLabel.set("theme", theme_default)
				if i == 0:
					theLabel.text = "The"
				else:
					theLabel.text = "the"
				theLabel.theme = wordstyle
				$labelBucket.add_child(theLabel)
				_position(theLabel)
		# IF NO "THE" PUT BEFORE THE WORD BUT THIS IS THE FIRST WORD UPPERCASE FIRST LETTER
			elif i == 0:
				leText[i]["word"] = leText[i]["word"][0].to_upper() + leText[i]["word"].substr(1, -1)

		# INSERT WORD
			var wordLabel = Label.new()
			# CHECK IF THE OBJECT OF THE SENTENCE IS THE CURRENT WORD
			# IF YES, IT CHANGE IT TO "IT"
			if leText[i]["word"] == textObject:
				wordLabel.text = "it"
			else:
				wordLabel.text = leText[i]["word"]
			if leText[i-1]["type"] != "afterword":
				textObject = leText[i]["word"]
			wordLabel.theme = wordstyle
			wordLabel.set_script(wordscript)
			wordLabel.ID = i
			
			$labelBucket.add_child(wordLabel)
			_position(wordLabel)
			
	# INSERT COMMA
		if i != 0 and (leText[i-1]["type"] == "list" or leText[i-1]["type"] == "afterword"):
			if leText[i-1]["word"] != "" and i+1 < leText.size() and leText[i+1]["type"] == "list":
				var commaLabel = Label.new()
				commaLabel.theme = wordstyle
				commaLabel.text = ","
				$labelBucket.add_child(commaLabel)
				_position(commaLabel)
			# INSERT "AND" AFTER COMMA
				var andLabel = Label.new()
				andLabel.theme = wordstyle
				andLabel.text = "and"
				$labelBucket.add_child(andLabel)
				_position(andLabel)
			# REMOVE PREVIOUS "AND" IF NOT NEEDED
				if commaCombo == true and andHold != null:
					andHold["node"].queue_free()
					cursor.position = andHold["cursor_position"]
					for label in range(andHold["index"], $labelBucket.get_child_count()):
						if $labelBucket.get_child(label).name != "wordlist":
							_position($labelBucket.get_child(label))
					andHold["node"] = andLabel
					andHold["index"] = andLabel.get_index()
					andHold["cursor_position"] = andLabel.rect_position
				commaCombo = true
			else:
				commaCombo = false
				andHold = null

	# INSERT AFTERWORDS OR AFTERLIST
		if leText[i]["type"] == "afterword":
			if leText[i].has("list"):
				var newListButt = Label.new()
				newListButt.set("theme", theme_default)
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
				afterLabel.theme = wordstyle
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
	if node is Label and (node.text == "," or node.text == ""):
		cursor.position[0] -= 8
	var labelBucket_right = $labelBucket.get("rect_position").x + $labelBucket.get("rect_size").x
	if node is TextureButton:
		node.rect_position = cursor.position - Vector2(24, 8)
	else:
		if cursor.position[0] + node.get("rect_size").x > $labelBucket.get("rect_size").x:
			cursor.position[0] = cursor_starting_x
			cursor.position[1] += 25
		node.rect_position = cursor.position
		cursor.position[0] += node.rect_size[0] + 8

func _on_wordlist_item_selected(index):
	
# CHANGE BUTTON TEXT
	for butt in listbutts:
		if butt.ID == activeButton:
			leText[butt.ID]["word"] = $labelBucket/wordlist.get_item_text(index)
			


# HANDLE AFTERWORD AND NEXT LIST/AFTERWORD
	var afterword = ""
	var word = $labelBucket/wordlist.get_item_text(index).replace(" ", "_")
	if Categories["afterwords"].has(word):
		afterword = Categories["afterwords"][word]

	if activeButton+2 < leText.size():
		if Categories["afterwords"].has(word):
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
		if Categories["afterwords"].has(word):
			if typeof(afterword) == 4:
				leText.insert(activeButton+2, {type = "afterword", word = str(afterword)})
			else:
				leText.insert(activeButton+2, {type = "afterword", word = "", list = afterword})

# PUT BACK LIST
	$labelBucket/wordlist.rect_position = Vector2(-2000, -2000)
	$labelBucket/wordlist.clear()
	$labelBucket/wordlist.set_auto_height(true)
	$labelBucket/wordlist.rect_size[1] = 0
		
	_draw_text()

func _check_answer():
	pass
