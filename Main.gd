extends Spatial

onready var progress = PROGRESS
onready var player = $Player
onready var cam = $Playercam
export var questions = [{question = "", solution = ""}, {question = "", solution = ""}, {question = "", solution = ""}]

func _ready():
	$GUI._add_question(0)

#func load_cutscene(scene):
#	for character in scene:
#		var current_char = get_node("NPCs/" + character)
#		current_char.cutscene = cutscene[character]

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		progress.cutscene = true
