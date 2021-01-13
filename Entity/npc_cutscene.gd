extends Spatial

onready var progress = PROGRESS
onready var animplayer = get_node("AnimationPlayer")
onready var navigation = get_node("../../Navigation")
onready var root = self.owner
onready var textbox = root.get_node("GUI/Dialogue")

export var Name = ""
export var dialogue = ""

var cutscene_block = []
var blocksegment = 0

var scenestep = 0
var beginstagestep = true
var stagestep = 0

var position = Vector3()
var walking = false
var walkhandled = false
var triggered = false

var path = []

var draw_path = true

var m = SpatialMaterial.new()

var progressblock = false

const SPEED = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var dialogue = get_tree().get_root().get_child(1).get_node("GUI").get_node("Dialogue")
	dialogue.connect("dialogue_progress", self, "dialogue_progress")

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

	### CUTSCENE ###

	if cutscene_block.size() > 0:
		#HANDLE ANIMATION#
		if cutscene_block[blocksegment].has("animation"):
			if animplayer.get_current_animation() == "":
					match cutscene_block[blocksegment]["animprogress"]:
						"idle":
							animplayer.play("Robot_Idle-loop")
		#					progress.npc[Name+"_animation"] = "Robot_Idle"
							cutscene_block[blocksegment]["animation"] = "Robot_Idle-loop"
							progressblock = true
						"stop":
							if progressblock == false:
								cutscene_block[blocksegment]["animation"] = ""
								progressblock = true
	
			if cutscene_block[blocksegment].has("animation"):
				if cutscene_block[blocksegment]["animation"]  != animplayer.get_current_animation():
					animplayer.play(cutscene_block[blocksegment]["animation"])
					progressblock = false

		#HANDLE MOVING#
		if cutscene_block[blocksegment].has("walk") and walking == false and walkhandled == false:
			var splitpos = cutscene_block[blocksegment]["walk"].split(",")
			position = Vector3(splitpos[0], splitpos[1], splitpos[2])
			_make_path(root.translation, position)
			walking = true
#			navigation._update_path(root, root.translation, position)

		#TRIGGER#
		if cutscene_block[blocksegment].has("trigger"):
			if cutscene_block[blocksegment].has("next"):
				match cutscene_block[blocksegment]["trigger"]:
					"position":
						if self.translation.distance_to(position) < 0.001:
							var next = cutscene_block[blocksegment]["next"].split("_")
							textbox.initiate(next[0], next[1])
			else:
				pass

##WALK##
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
				if walking == true:
					walkhandled = true
					print(self.translation.distance_to(position))
				walking = false
		else:
#			anim_to_play = "Robot_Idle-loop"
			walking = false
			if walking == true:
				walkhandled = true
				print(str(self.translation) + " " + str(position))

func dialogue_progress():
	cutscene_block = []
	var segment = {}
	var block_segment = 1
	walkhandled = false
	path = []
	for key in progress.npc.keys():
		var keyparts = key.split("_")
		if keyparts[0] == Name:
			if int(keyparts[2]) == block_segment:
				segment[keyparts[1]] = progress.npc[key]
			if int(keyparts[2]) > block_segment:
				cutscene_block.append(segment)
				segment = {}
				segment[keyparts[1]] = progress.npc[key]
			if int(keyparts[2]) < block_segment:
				cutscene_block[keyparts[2]-1][keyparts[1]] = progress.npc[key]
	cutscene_block.append(segment)
	print(cutscene_block)


func _make_path(begin, end):
	path = navigation.get_simple_path(begin, end, true)
	path.invert()
#	path = Array(p) # Vector3array too complex to use, convert to regular array
#func dialogue_progress():
#	read_dialogue()

	

	### OLD CUTSCENE SYSTEM ###
#	if progress.scenestep > 0:
#		#First, where even are we in the cutscene
#		if scenestep != progress.scenestep:
#			scenestep = progress.scenestep
#			stagestep = 0
#			beginstagestep = true
#		var stage = cutscene[String(progress.scenestep)][stagestep]
#		#Then, act accordingly
#		if beginstagestep == true:
#			match stage["type"]:
#				"walk_to":
#					var position = Vector3(stage["position"][0], stage["position"][1], stage["position"][2])
#					navigation._update_path(self, self.translation, position)
#					animplayer.play("Robot_Walking-loop")
#				"animation":
#					animplayer.play(stage["animation"])
#			beginstagestep = false
#
#		#See if triggered to next stage
#		match stage["trigger"]:
#			"on_position":
#				if self.translation.floor() == Vector3(stage["position"][0], stage["position"][1], stage["position"][2]).floor():
#					triggered = true
#			"dialogue":
#				if scenestep != progress.scenestep:
#					if scenestep == 0:
#						scenestep = 1
#					if scenestep != 0:
#						triggered = true
#			"animation":
#				if animplayer.is_playing() == false and animplayer.get_queue().size() == 0:
#					triggered = true
#
#		#If triggered, go to next stage
#		if triggered == true:
#			triggered = false
#			beginstagestep = true
#			stagestep += 1
#		#Loop
#			if stage.has("loop_from"):
#				stagestep = stage["loop_from"]

#get_node("../../Navigation")._update_path(self, self.translation, Vector3(8.386, 0, -0.091))
#func finished(anim):
#	if anim == "Robot_Idle":
#		animplayer.play("Robot_Idle", -1, 1)
