extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var ID = 0
var list = []
var desc = ""
var attributes = []
var active = false
onready var FollowButt = get_node("../../FollowButt")
onready var wordlist = get_node("../wordlist")
onready var progress = PROGRESS


func _ready():
	button_mask = 3

func _process(delta):
		
	if active == true:
		self.modulate = Color(1, 0.5, 0.5, 1)
	else:
		self.modulate = Color(1, 1, 1, 1)
		if progress.selected_clue.has("name"):
			if progress.selected_clue["name"] == self.text:
				progress.selected_clue = {}

	if Input.is_action_just_pressed("mouse_right") and not self.pressed:
		active = false

	if Input.is_action_just_pressed("mouse_left"):
		active = false
		if self.pressed:
			get_parent().get_parent()._add_text(self.text, self.list)

	if Input.is_action_just_pressed("mouse_right") and self.pressed:
		active = true
		get_parent().get_parent().clue_selected = 1
		progress.selected_clue["name"]= self.text
		progress.selected_clue["list"] = self.list
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
	if _mousein() == true:
		progress.desc = desc

func _mousein():
	var mouseX = get_viewport().get_mouse_position()[0]
	var mouseY = get_viewport().get_mouse_position()[1]
	var rectX = self.rect_position[0]
	var rectY = self.rect_position[1]
	var rectSX = self.rect_size[0]
	var rectSY = self.rect_size[1]
	var parentX = self.get_parent().rect_position[0]
	var parentY = self.get_parent().rect_position[1]
	var parentSX = self.get_parent().rect_size[0]
	var parentSY = self.get_parent().rect_size[1]
	
	
#	print("Rect: " + str(self.ID) + ": " + str(rectX + parentX) + ", " + str(rectY + parentY))	
#	print("Mouse: " + str(get_viewport().get_mouse_position()[0]) + ", " + str(get_viewport().get_mouse_position()[1]))
	
	if mouseX > rectX + parentX and mouseX < rectX + rectSX + parentX and mouseY > rectY + parentY and mouseY < rectY + rectSY + parentY:
		return true
	else:
		return false
#func _pressed():
##	if type == "cluebutt":
##
##		FollowButt.rect_size = self.rect_size
##		FollowButt.text = self.text
##		FollowButt.list = self.list
##		FollowButt.rect_position = self.rect_position
##		FollowButt.follow = true
##		FollowButt.distdiff = get_viewport().get_mouse_position() - self.rect_position
##
#	if type == "listbutt":
#		get_parent().get_parent().activeButton = self.ID
#		wordlist.clear()
#		wordlist.rect_size[1] = self.list.size() * 20
#
#		for word in self.list:
#			wordlist.add_item(word)
#
#		wordlist.rect_position = Vector2(self.rect_position[0], self.rect_position[1] + self.rect_size[1])
#		wordlist.rect_size[0] = self.rect_size[0]
##	print("Mouse pos: " + str(get_viewport().get_mouse_position()))