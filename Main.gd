extends Spatial

onready var progress = PROGRESS
onready var player = $Player
onready var cam = $Playercam
var questions = [{question = "What?"},{question = "When?"},{question = "Why?"}]

func _ready():
	pass

#func load_cutscene(scene):
#	for character in scene:
#		var current_char = get_node("NPCs/" + character)
#		current_char.cutscene = cutscene[character]

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		progress.cutscene = true
