extends Control

onready var progress = PROGRESS
var outline_big = load("res://assets/Fonts/Outline_big.tres")

onready var root = get_tree().get_current_scene()
onready var buttlist = $"QuestionList/QuestButtList"
onready var player = $"../Detective"
onready var camera = $"../Playercam"
onready var menu = $"Menu"
onready var cluesbutt = $"Menu/Cluesbutt"
onready var questbutt = $"Menu/Questionsbutt"
onready var indictbutt = $"Menu/Indictbutt"
onready var dialogue = $"Dialogue"
onready var clueslist = $"Cluelist"
onready var questlist = $"QuestionList"
onready var thought = $"Thought system"
onready var present = $"Present list"
onready var indict = $"Indict"
onready var fps_label = get_node("fps_label")

var cluelist = {}
var qid = 0
var clue = ""

func _ready():
	menu.hide()
	clueslist.hide()
	questlist.hide()
	thought.hide()
#	for question in root.questions:
#
#		thought.leQuestions[qid] = {question = root.questions[qid]["question"], answer = [], raw_answer = ""}
#
#		var button = Button.new()
#		var separator = HSeparator.new()
#
#		button.text = question["question"]
#		button.set_focus_mode(0)
#		button.rect_min_size[1] = 40
#		separator.rect_min_size[1] = 30
#
#		button.connect("pressed", self, "_thought", [qid])
#
#		qid += 1
#
#		buttlist.add_child(button)
#		buttlist.add_child(separator)

func _process(delta):
	
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
	
#	fps_label.set_text( str(Engine.get_frames_per_second()) + "\n scenestep: " + 
#	String(progress.scenestep) + "\n Robo step: " + String(get_node("../NPCs/Robot").scenestep) +
#	"\n Robo stage: " + String(get_node("../NPCs/Robot").stagestep))

	if progress.mousemode == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$tablet.visible = progress.pause

	if Input.is_action_just_pressed("button1"):
		match progress.gui:
			0:
				progress.pause = true
				menu.show()
				if progress.mousemode == false:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					progress.control = false
				progress.gui = 1
#				print(thought.leQuestions)
			1:
				progress.pause = false
				menu.hide()
				if progress.mousemode == false:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					progress.control = true
				progress.gui = 0
			2, 3, 5:
				questlist.hide()
				clueslist.hide()
				indict.hide()
				menu.show()
				progress.gui = 1
			4:
				thought.hide()
				progress.desc = ""
				questlist.show()
				progress.gui = 3

#	if Input.is_action_just_pressed("button3"):
#		print(cluelist)
#		print(progress.list)
#		thought._add_clue({"word": "Letters", "desc": "Some letter the victim sent to Espella over the years", "attributes": ["small"]})

	if cluesbutt.pressed:
		clueslist._makelist()
		menu.hide()
		clueslist.show()
		progress.gui = 2

	if questbutt.pressed:
		questlist.show()
		menu.hide()
		progress.gui = 3

	if indictbutt.pressed:
		indict.show()
		menu.hide()
		progress.gui = 5

	if dialogue.frame.is_visible() == false and clueslist.is_visible() == false:
		camera.control = progress.control
	else:
		camera.control = false
		
	if progress.variables["present"] == "true":
		clueslist._makelist()
		clueslist.show()
		progress.pause = true
		$Present_button.show()
		if progress.mousemode == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		progress.variables["present"] = "on"

	if progress.variables["add_clue"] == "true":
		thought._add_clue()
		progress.variables["add_clue"] = "false"

	if progress.variables["question"] != null:
		_add_question(int(progress.variables["question"]))
		progress.variables["question"] = null

func _thought(qid):
	progress.gui = 4
	questlist.hide()
	thought.show()
	thought._setup(qid)


func _on_Present_button_pressed():
	var list = $Cluelist/ItemList
	if list.get_selected_items().size() > 0:
		var selected = list.get_item_text(list.get_selected_items()[0])
		if progress.mousemode == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		clueslist.hide()
		$Present_button.hide()
		progress.pause = false
		# If the npc have dialog for the presented evidence
		if dialogue.has_block(progress.current_dialogue, selected):
			# set this variable to true so it gonna save the dialogue into log 
			progress.present = true
			# Create a new tab in logs if the npc don't have one already
			if !get_node_or_null("Cluelist/LogContainer/" + progress.current_dialogue):
				print(progress.current_dialogue + " tab created in logs")
				
				var newTab = VBoxContainer.new()
				newTab.name = progress.current_dialogue
				newTab.set("size_flags_horizontal", SIZE_EXPAND_FILL)
				newTab.set("size_flags_vertical", SIZE_EXPAND_FILL)

				var newRichLabel = RichTextLabel.new()
				newRichLabel.set("size_flags_horizontal", SIZE_EXPAND_FILL)
				newRichLabel.set("size_flags_vertical", SIZE_EXPAND_FILL)
				newRichLabel.set("margin_left", 20)
				newRichLabel.set("margin_top", 40)
				newRichLabel.set("margin_right", -20)
				newRichLabel.set("margin_bottom", -20)

				newTab.add_child(newRichLabel)
				$Cluelist/LogContainer.add_child(newTab)
			# set the variable so later can be known what evidence to use
			clue = selected
			# start the dialog
			dialogue.initiate(progress.current_dialogue, selected)
		else:
			# if npc don't have a dialog for evidence start the present dialogue
			dialogue.initiate(progress.current_dialogue, "present")

func _add_question(id):
	var question = root.questions[id]
	thought.leQuestions[qid] = {question = root.questions[qid]["question"], answer = [], raw_answer = ""}

	var button = Button.new()
	var separator = HSeparator.new()

	button.text = question["question"]
	button.set_focus_mode(0)
	button.rect_min_size[1] = 40
	button.set("custom_fonts/font", outline_big)
	separator.rect_min_size[1] = 30

	button.connect("pressed", self, "_thought", [qid])

	if qid != 0:
		buttlist.add_child(separator)
	buttlist.add_child(button)

	qid += 1

func _presentlog(present_log):
	# If the evidence don't have a log for that evidence yet create place in the dict
	if !cluelist[clue]["log"].has(progress.current_dialogue):
		cluelist[clue]["log"][progress.current_dialogue] = ""
	# Add the dialogue piece to the log
	if present_log["type"] == "text":
		cluelist[clue]["log"][progress.current_dialogue] += present_log["name"] + ": " + present_log["content"] + "\n\n"

func _draw():
	draw_circle(get_viewport().get_size()/2, 2, Color("ffffff"))
