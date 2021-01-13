extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const CHAR_SCALE = Vector3(1, 1, 1)

var root_motion = Transform()
var current_anim = "walk"
var motion = 0
var linear_velocity=Vector3()
var movement_dir = Vector3()
var trans = Transform()

var control = true
var max_speed = 2
var turn_speed = 20
var accel = 19.0
var deaccel = 14.0
var sharp_turn_threshold = 140

var walking = false
var path = []

var skele = null
var ray = null

var skel
var right_foot_ik

var animation = "idle"

onready var progress = PROGRESS
#onready var ray = get_node("rig/Skeleton/RayCast")
onready var textbox = get_node("../GUI/Dialogue")
onready var animplayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animation_mode = animationTree.get("parameters/playback")
onready var playback = animationTree.get("parameters/StateMachine/playback")

func _ready():

	skel = get_node("Armature/Skeleton")
	ray = get_node("Armature/Skeleton/RayCast")

func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
	var n = p_target # Normal
	var t = n.cross(current_gn).normalized()
	 
	var x = n.dot(p_facing)
	var y = t.dot(p_facing)
	
	var ang = atan2(y,x)
	
	if (abs(ang) < 0.001): # Too small
		return p_facing
	
	var s = sign(ang)
	ang = ang*s
	var turn = ang*p_adjust_rate*p_step
	var a
	if (ang < turn):
		a = ang
	else:
		a = turn
	ang = (ang - a)*s
	
	return (n*cos(ang) + t*sin(ang))*p_facing.length()

func _physics_process(delta):

	var lv = linear_velocity
	var g = Vector3(0,-9.8,0)
#	var motion = 0

	lv += g*delta # Apply gravity

	var up = -g.normalized() # (up is against gravity)
	var vv = up.dot(lv) # Vertical velocity
	var hv = lv - up*vv # Horizontal velocity
	
	root_motion = animationTree.get_root_motion_transform()
	var hdir = hv.normalized() # Horizontal direction
	var hspeed = hv.length() # Horizontal speed


	var dir = Vector3() # Where does the player intend to walk to

	var cam_xform = get_node("../Playercam").get_global_transform()

	if control == true:
		if (Input.is_action_pressed("forward")):
			dir += -cam_xform.basis[2]
		if (Input.is_action_pressed("backward")):
			dir += cam_xform.basis[2]
		if (Input.is_action_pressed("left")):
			dir += -cam_xform.basis[0]
		if (Input.is_action_pressed("right")):
			dir += cam_xform.basis[0]

	if dir.length() > 0:
		animation_mode.travel("Walk")
		animation = "Walk"
#		if motion == 0:
#			$AnimationPlayer.get_animation("walk").set()
		if motion < 0:
			motion += 0.1
		if Input.is_action_pressed("shift"):
			if motion < 1:
				motion += 0.1
		elif motion > 0:
			motion -= 0.1
	else:
		animation_mode.travel("Idle")
		animation = "Idle"
		
#		if motion > 0:
#			motion -= 0.1

#	if motion != 0:
#		if Input.is_action_pressed("shift"):
#			if motion < 2:
#				motion += 0.1
#		elif motion > 1:
#			motion -= 0.1

	var target_dir = (dir - up*dir.dot(up)).normalized()

	if (is_on_floor()):
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold


		animationTree.set("parameters/walk/blend_position", motion)
		animationTree.get("parameters/StateMachine/playback")
		if (dir.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				hdir = adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
#				facing_dir = hdir
			else:
				hdir = target_dir

		hspeed = root_motion.origin.length()*60
		hv = hdir*hspeed

		var mesh_xform = skel.get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()
		
		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)
		
		skel.set_transform(Transform(m3, mesh_xform.origin))

	lv = hv + up*vv
	
	if is_on_floor():
		movement_dir = lv

	linear_velocity = move_and_slide_with_snap(lv, Vector3(0, -6, 0), Vector3(0, 1, 0), true, 4, deg2rad(30), false)

### WE ANIMATE NOW ###

#	var anim_to_play = "Idle-loop"
#
#	if hspeed > 0:
#		anim_to_play = "Walk-loop"
#
#	var current_animation = animplayer.current_animation
#	if current_animation != anim_to_play:
#		animplayer.play(anim_to_play)
	
	
###	CAST SOME RAY ###

func _process(delta):
	
#	$Label.text = ik_right_dir

#	$Cube.global_transform.origin = $Armature/Skeleton/BoneAttachment.global_transform.origin
	
### RAYCAST ###
	if ray.is_colliding():
		progress.current_talkdialogue = ray.get_collider().talk_dialogue
	else:
		progress.current_talkdialogue = ""
		
	if Input.is_action_just_pressed("mouse_left") and progress.current_talkdialogue != "" and $"../Playercam".firstmode == false:
		if textbox.dialogue == null:
			textbox.initiate(progress.current_talkdialogue)
		else:
			textbox.next()

	if walking == true:
		$rig/Skeleton.rotation_degrees[1] = 0
		if (path.size() > 1):
			var to_walk = delta*max_speed
			var to_watch = Vector3(0, 1, 0)
			while(to_walk > 0 and path.size() >= 2):
				var pfrom = path[path.size() - 1]
				var pto = path[path.size() - 2]
				to_watch = (pto - pfrom).normalized()
				var d = pfrom.distance_to(pto)
				if (d <= to_walk):
					path.remove(path.size() - 1)
					to_walk -= d
				else:
					path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
					to_walk = 0
			
			var atpos = path[path.size() - 1]
			var atdir = to_watch
			atdir.y = 0
			
			var t = Transform()
			t.origin = atpos
			t=t.looking_at(atpos - to_watch, Vector3(0, 1, 0))
			self.set_transform(t)

			
			if (path.size() < 2):
				path = []
				walking = false
		else:
			walking = false

	var fps = Engine.get_frames_per_second()
