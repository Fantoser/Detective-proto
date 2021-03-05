extends TextureButton

var rectpos = self.rect_position
var rectsize = self.rect_size
onready var root = self.get_parent().get_parent()
onready var progress = PROGRESS
var ID = 0

func _ready():
	rectsize = self.rect_size
	rectpos = self.get_global_position()
	self.visible = false

func _process(delta):
	if rectpos != self.get_global_position():
		rectpos = self.get_global_position()
	var mousepos = get_viewport().get_mouse_position()
	

	if root.clue_selected != 0:
		self.visible = true

	if Input.is_action_just_pressed("mouse_left"):
		if pressed:
			root._add_text(progress.selected_clue["name"], progress.selected_clue["list"], ID)
		else:
			self.visible = false
			
#	if root.clue_selected == false:
#		$ColorRect.visible = false
	
#	if mousepos[0] > rectpos[0] and mousepos[0] < rectpos[0] + rectsize[0] and mousepos[1] > rectpos[1] and mousepos[1] < rectpos[1] + rectsize[1]:
#		$ColorRect.visible = true
#	else:
#		$ColorRect.visible = false


