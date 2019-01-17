extends Camera

# class member variables go here, for example:
export var distance = 4.0
export var height = 2.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_physics_process(true)
#	set_as_toplevel(true)
	set_process_input(true)
	
func _input(event):
	##
	## We'll only process mouse motion events
	if event is InputEventMouseMotion:
		return mouse(event)


func mouse(event):
#	rotation = get_parent().get_rotation() + Vector3(event.relative.x / -200, 0, 0)
	get_parent().rotate_z(event.relative.x / -200)
#	self.rotate_x(event.relative.y / -200)
	
func _enter_tree():
	"""
	Hide the mouse when we start
	"""
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _leave_tree():
	"""
	Show the mouse when we leave
	"""
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin
	var up = Vector3(0,1,0)
	
	var offset = pos - target
	
	offset = offset.normalized()*distance
	offset.y = height
	
	pos = target + offset
	
	look_at_from_position(pos, target, up)

