extends Spatial

onready var animplayer = $AnimationPlayer
var speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	animplayer.connect("animation_finished", self, "finished")
	animplayer.play("ArmatureAction")


func finished(anim):
	if anim == "ArmatureAction":
		animplayer.play("E", -1, speed)
		speed += 0.01
	if anim == "E":
		animplayer.play("ArmatureAction", -1, speed)
		speed += 0.01

	
	
#func _process(delta):
#	pass
