extends KinematicBody

var root_motion = Transform()
var orientation
var motion = Vector2()
var current_anim = "walk"

onready var skeleton = get_node("Armature/Skeleton")
onready var animationTree = $AnimationTree
onready var  playback = animationTree.get("parameters/StateMachine/playback")

onready var cam = get_node("../Playercam")

# Called when the node enters the scene tree for the first time.
func _ready():
	orientation = global_transform
	orientation.origin = Vector3()

func _physics_process(delta):

	var q_from = Quat(orientation.basis)
	var q_to = Quat()

	var cam_z = - cam.global_transform.basis.z
	var cam_x = cam.global_transform.basis.x

	if Input.is_action_pressed("ui_up"):
		if motion.y < 1:
			motion.y += 0.5
	else:
		if motion.y > 0:
			motion.y -= 0.5

	if Input.is_action_pressed("shift"):
		current_anim = "sneak"
		playback.travel("sneak")

	if Input.is_action_just_released("shift"):
		current_anim = "walk"
		playback.travel("walk")

	animationTree.set("parameters/StateMachine/" + current_anim + "/blend_position", motion.y)

	var target = - cam_x * motion.x -  cam_z * motion.y

	q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)

	# interpolate current rotation with desired one
	orientation.basis = Basis(q_from.slerp(q_to,delta*10))
	orientation.basis.y = Vector3(0,1,0)

	root_motion = animationTree.get_root_motion_transform()

	orientation *= root_motion

	var h_velocity = orientation.origin / delta
	var velocity = Vector3(h_velocity.x, 0, h_velocity.z)
	velocity = move_and_slide_with_snap(velocity, Vector3(0, -1, 0), Vector3(0, 1, 0), true)
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	var trans = Transform(orientation.basis, self.global_transform.origin)
	self.global_transform = trans
