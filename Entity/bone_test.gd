extends Spatial


var skel
var id


# Called when the node enters the scene tree for the first time.
func _ready():
	skel = get_node("Armature/Skeleton")
	id = skel.find_bone("AL01")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = skel.get_bone_pose(id)
	t = t.rotated(Vector3(0.0, 1.0, 0.0), 0.1 * delta)
	skel.set_bone_pose(id, t)
