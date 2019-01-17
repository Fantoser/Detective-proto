extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player = $Player
onready var cam = $Playercam

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	$Label.text = "player basis: " + str(rad2deg(player.get_rotation().y)) + "\ndir: " + str(player.dir) + "\nvelocity: " + str(player.velocity.y) + "\nhvel: " + str(player.hvel) + "\ncam basis: " + str(cam.get_global_transform().basis[0])