extends Button

var ID = 0
var list = []
var desc = ""
var attributes = []
var active = false
var person = false
onready var FollowButt = get_node("../../FollowButt")
onready var wordlist = get_node("../wordlist")
onready var progress = PROGRESS


func _ready():
	button_mask = 3

func _process(delta):
		
	if active == true:
		self.modulate = Color(0.5, 0.5, 1, 1)
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
			var word = self.text
			if person == false:
				word = word.to_lower()
			get_parent().get_parent().get_parent()._add_text(word, self.list)

	if Input.is_action_just_pressed("mouse_right") and self.pressed:
		active = true
		get_parent().get_parent().get_parent().clue_selected = 1
		if person == false:
			progress.selected_clue["name"]= self.text.to_lower()
		else:
			progress.selected_clue["name"]= self.text
		progress.selected_clue["list"] = self.list

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


func _on_Abutt_mouse_entered():
	if progress.gui == 4:
		progress.desc = desc
