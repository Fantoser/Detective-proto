extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const CHAR_SCALE = Vector3(0.291, 0.291, 0.291)

var linear_velocity=Vector3()
var movement_dir = Vector3()
var trans = Transform()

var control = true
var max_speed = 2
var turn_speed = 40
var accel = 19.0
var deaccel = 14.0
var sharp_turn_threshold = 140

var walking = false
var path = []

onready var progress = PROGRESS
onready var ray = get_node("rig/Skeleton/RayCast")
onready var textbox = get_node("../GUI/Dialogue")
onready var animplayer = $AnimationPlayer

#func _ready():
#	$rig/Skeleton.rotation_degrees[1] = -90
##	print(get_node("rig").get_transform().origin)

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
	
	lv += g*delta # Apply gravity
	
	var up = -g.normalized() # (up is against gravity)
	var vv = up.dot(lv) # Vertical velocity
	var hv = lv - up*vv # Horizontal velocity
	
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

	var target_dir = (dir - up*dir.dot(up)).normalized()
	
	if (is_on_floor()):
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold
		
		if (dir.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				hdir = adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
#				facing_dir = hdir
			else:
				hdir = target_dir
			
			if (hspeed < max_speed):
				hspeed += accel*delta
		else:
			hspeed -= deaccel*delta
			if (hspeed < 0):
				hspeed = 0
		
		hv = hdir*hspeed
		
		var mesh_xform = get_node("rig/Skeleton").get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()
		
		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)
		
		get_node("rig/Skeleton").set_transform(Transform(m3, mesh_xform.origin))

	lv = hv + up*vv
	
	if (is_on_floor()):
		movement_dir = lv
		
	linear_velocity = move_and_slide(lv,-g.normalized())
#	get_node("../Label").text = str(hspeed)
	
### WE ANIMATE NOW ###

	var anim_to_play = "Idle-loop"

	if hspeed > 0:
		anim_to_play = "Walk-loop"

	var current_animation = animplayer.current_animation
	if current_animation != anim_to_play:
		animplayer.play(anim_to_play)
	
	
###	CAST SOME RAY ###

func _process(delta):
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
#			adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)

			
			if (path.size() < 2):
				path = []
				walking = false
		else:
			walking = false


#	if Input.is_action_just_pressed("mouse_left") and textbox.dialogue != null and textbox.dialogue != null:
#		textbox.next()