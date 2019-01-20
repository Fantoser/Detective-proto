extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const CHAR_SCALE = Vector3(1, 1, 1)

var linear_velocity=Vector3()
var facing_dir = Vector3(1, 0, 0)
var movement_dir = Vector3()

var max_speed = 6
var turn_speed = 40
var accel = 19.0
var deaccel = 14.0
var sharp_turn_threshold = 140

onready var ray = get_node("Pbody/RayCast")

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
				facing_dir = hdir
			else:
				hdir = target_dir
			
			if (hspeed < max_speed):
				hspeed += accel*delta
		else:
			hspeed -= deaccel*delta
			if (hspeed < 0):
				hspeed = 0
		
		hv = hdir*hspeed
		
		var mesh_xform = get_node("Pbody").get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()
		
		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)
		
		get_node("Pbody").set_transform(Transform(m3, mesh_xform.origin))

	lv = hv + up*vv
	
	if (is_on_floor()):
		movement_dir = lv
		
	linear_velocity = move_and_slide(lv,-g.normalized())
	
	
###	CAST SOME RAY ###

func _process(delta):
	if ray.is_colliding():
		var rayObject = ray.get_collider()
