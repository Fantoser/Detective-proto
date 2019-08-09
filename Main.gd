extends Spatial

onready var progress = PROGRESS
onready var player = $Player
onready var cam = $Playercam
var questions = [{question = "What?"},{question = "When?"},{question = "Why?"}]

var cutscene = {
	"Robot":{
		"1":[
			{
				"type":"animation",
				"animation":"Robot_ThumbsUp",
				"trigger":"dialogue"
			}
		],
		"2":[
			{
				"type":"walk_to",
				"position":[8.386, 0, -0.091],
				"animation":"Robot_walk-loop",
				"trigger":"on_position"
			},
			{
				"type":"animation",
				"animation":"Robot_Punch",
				"trigger":"animation"
			},
			{
				"type":"animation",
				"animation":"Robot_Yes",
				"trigger":"animation"
			},
			{
				"type":"walk_to",
				"position":[-7.465, 0, 8.493],
				"animation":"Robot_walk-loop",
				"trigger":"on_position"
			},
			{
				"type":"animation",
				"animation":"Robot_Wave",
				"trigger":"animation",
				"loop_from":0
			},
		],
		"3":[
			{
				"type":"animation",
				"animation":"Robot_Punch",
				"trigger":"dialogue"
			}
		],
		"4":[
			{
				"type":"animation",
				"animation":"Robot_Dance-loop"
			}
		]
	}
}

func _ready():
	load_cutscene(cutscene)

func load_cutscene(scene):
	for character in scene:
		var current_char = get_node("NPCs/" + character)
		current_char.cutscene = cutscene[character]

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		progress.cutscene = true
		
#	if Input.is_action_just_pressed("button1"):
#		dialogue.initiate("test_dialogue")
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	$Label.text = "player basis: " + str(rad2deg(player.get_rotation().y)) + "\ndir: " + str(player.dir) + "\nvelocity: " + str(player.velocity.y) + "\nhvel: " + str(player.hvel) + "\ncam basis: " + str(cam.get_global_transform().basis[0])
#	$Label.text = str($Luke.hspeed)