extends KinematicBody

var control = true

var floor_angle = Vector3()

var velocity = Vector3()
var direction = Vector3()

#walk variables
var gravity = -9.8 * 3
const MAX_SPEED = 5
const MAX_RUNNING_SPEED = 30
const ACCEL = 2
const DEACCEL = 10

var has_contact = false

#slope variables
const MAX_SLOPE_ANGLE = 35

const CHAR_SCALE = Vector3(0.291, 0.291, 0.291)
var sharp_turn_threshold = 120
var turn_speed = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	walk(delta)

func walk(delta):
	
	var gravity_vector = Vector3(0,-9.8,0)
	var up = -gravity_vector.normalized() # (up is against gravity)
	var vv = up.dot(velocity) # Vertical velocity
	var hv = velocity - up*vv # Horizontal velocity
	
	var hdir = hv.normalized() # Horizontal direction
	var hspeed = hv.length() # Horizontal speed
	
	# reset the direction of the player
	direction = Vector3()

	# get the rotation of the camera
	var aim = get_node("../Playercam").get_global_transform().basis

		# check input and change direction
	if Input.is_action_pressed("forward"):
		direction -= aim.z
	if Input.is_action_pressed("backward"):
		direction += aim.z
	if Input.is_action_pressed("left"):
		direction -= aim.x
	if Input.is_action_pressed("right"):
		direction += aim.x
	
	direction.y = 0
	direction = direction.normalized()

	velocity.y += gravity * delta

	if (has_contact and !is_on_floor()):
		move_and_collide(Vector3(0, -1, 0))

	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	speed = MAX_SPEED

	# where would the player go at max speed
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL

	# calculate a portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)

	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z

	# move
	velocity = move_and_slide_with_snap(velocity, Vector3(0, -6, 0), Vector3(0, 1, 0), true, 4, deg2rad(30), false)
	
	#facing
	var target_dir = (direction - up*direction.dot(up)).normalized()
	
	if (is_on_floor()):
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if (direction.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				hdir = adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
			else:
				hdir = target_dir

			if (hspeed < MAX_SPEED):
				hspeed += ACCEL*delta
		else:
			hspeed -= DEACCEL*delta
			if (hspeed < 0):
				hspeed = 0

		var mesh_xform = get_node("rig/Skeleton").get_transform()
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()
		
		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)
		
		get_node("rig/Skeleton").set_transform(Transform(m3, mesh_xform.origin))
	
	
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
