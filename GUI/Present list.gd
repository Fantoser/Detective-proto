extends Control

onready var progress = PROGRESS
onready var gui = get_parent()
onready var list = get_node("Butt list")
onready var desc = get_node("Present desc")
onready var Pos = $"Butt list/Position"
onready var textbox = $"../Dialogue"
var button_Rborder = 210
var button_Lborder = 14
var button_Tborder = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _makelist():

	Pos.position[0] = button_Lborder
	Pos.position[1] = button_Tborder

	for child in list.get_children():
		if child.get_class() != "Position2D":
			child.queue_free()

	for item in gui.cluelist.keys():
		var butt = Button.new()
		butt.text = item
		butt.rect_size += Vector2(0, 30)
		butt.set_focus_mode(0)

		butt.connect("mouse_entered", self, "_change_desc", [butt.text])
		butt.connect("pressed", self, "_present", [butt.text])

		$"Butt list".add_child(butt)
		_position(butt)
	
func _position(node):
	if Pos.position[0] + node.rect_size[0] > button_Rborder:
		Pos.position[1] += 35
		Pos.position[0] = button_Lborder
	node.rect_position = Pos.position
	Pos.position[0] += node.rect_size[0] + 8


func _change_desc(clue):
	$"Present desc".text = gui.cluelist[clue]

func _present(clue):
	self.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if textbox.has_block(progress.current_dialogue, clue):
		textbox.initiate(progress.current_dialogue, clue)
	else:
		textbox.initiate(progress.current_dialogue, "present")
#	if progress.presentlist.find(clue, 0) != -1:
#		textbox.initiate(progress.current_dialogue + "_present", clue)
#	else:
#		textbox.initiate(progress.current_dialogue + "_present", "Nothing")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	_makelist()
