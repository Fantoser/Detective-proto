extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var follow = false
var active = false
var list = []
var distdiff = Vector2()
onready var letext = get_node("../the_text")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if follow == true:
		self.rect_position = get_viewport().get_mouse_position() - distdiff
		$FollowArea.position = Vector2(self.rect_size[0]/2,self.rect_size[1]/2)
		$FollowArea/FollowCollision.shape.set_extents(Vector2(self.rect_size[0]*2.7, self.rect_size[1]*1.3))
	else:
		self.rect_position = Vector2(-100, -100)
		
	if Input.is_action_just_released("mouse_left"):
		if active == true:
			get_parent()._add_text(self.text)
		follow = false



func _on_Area2D_area_entered(area):
	active = true


func _on_Area2D_area_exited(area):
	active = false