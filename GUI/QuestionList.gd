extends Control

onready var root = get_parent().get_parent()
onready var buttlist = $QuestButtList

# Called when the node enters the scene tree for the first time.
func _ready():
	for question in root.questions:
		print(question["question"])
		var button = Button.new()
		var separator = HSeparator.new()

		button.text = question["question"]
		button.set_focus_mode(0)
		button.rect_min_size[1] = 40
		separator.rect_min_size[1] = 30

		buttlist.add_child(button)
		buttlist.add_child(separator)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
