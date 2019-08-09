extends Spatial

onready var progress = PROGRESS
onready var animplayer = $AnimationPlayer
onready var navigation = get_node("../../Navigation")

export var Name = ""
export var dialogue = ""

var cutscene = {}
var scenestep = 0
var beginstagestep = true
var stagestep = 0

var walking = false
var triggered = false

var path = []

var draw_path = true

var m = SpatialMaterial.new()

var step = 1

const SPEED = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

### WE ANIMATE NOW ###

#	current_animation = animplayer.current_animation
#
#	if current_animation != anim_to_play:
#		if current_animation == "":
#			if animloop == true:
#				animplayer.play(anim_to_play)
#			else:
#				pass
#		else:
#			animplayer.play(anim_to_play)

##WALK
	if walking == true:
		if (path.size() > 1):
#			anim_to_play = "Robot_Walking-loop"
#			if animplayer.is_playing() == false:
#				animplayer.play("Robot_Walking-loop")
			var to_walk = delta*SPEED
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
			t=t.looking_at(atpos - atdir, Vector3(0, 1, 0))
			self.set_transform(t)
			
			if (path.size() < 2):
				path = []
#				anim_to_play = "Robot_Idle-loop"
				walking = false
		else:
#			anim_to_play = "Robot_Idle-loop"
			walking = false

	#E2

	if progress.scenestep > 0:
		#First, where even are we in the cutscene
		if scenestep != progress.scenestep:
			scenestep = progress.scenestep
			stagestep = 0
			beginstagestep = true
		var stage = cutscene[String(progress.scenestep)][stagestep]
		#Then, act accordingly
		if beginstagestep == true:
			match stage["type"]:
				"walk_to":
					var position = Vector3(stage["position"][0], stage["position"][1], stage["position"][2])
					navigation._update_path(self, self.translation, position)
					animplayer.play("Robot_Walking-loop")
				"animation":
					animplayer.play(stage["animation"])
			beginstagestep = false

		#See if triggered to next stage
		match stage["trigger"]:
			"on_position":
				if self.translation.floor() == Vector3(stage["position"][0], stage["position"][1], stage["position"][2]).floor():
					triggered = true
			"dialogue":
				if scenestep != progress.scenestep:
					if scenestep == 0:
						scenestep = 1
					if scenestep != 0:
						triggered = true
			"animation":
				if animplayer.is_playing() == false and animplayer.get_queue().size() == 0:
					triggered = true

		#If triggered, go to next stage
		if triggered == true:
			triggered = false
			beginstagestep = true
			stagestep += 1
		#Loop
			if stage.has("loop_from"):
				stagestep = stage["loop_from"]

#get_node("../../Navigation")._update_path(self, self.translation, Vector3(8.386, 0, -0.091))
#func finished(anim):
#	if anim == "Robot_Idle":
#		animplayer.play("Robot_Idle", -1, 1)