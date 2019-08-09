extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var ID = null
var type = null
var list = []

onready var FollowButt = get_node("../../FollowButt")
onready var wordlist = get_node("../wordlist")
var texture = preload("res://icon.png")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	var therect = Rect2(Vector2(self.rect_position), Vector2(self.rect_size))
	var background = NinePatchRect.new()
	background.texture = texture
	background.patch_margin_left = 7
	background.patch_margin_right = 7
	background.patch_margin_top = 9
	background.patch_margin_bottom = 9
	background.rect_position -= Vector2(5, 2)
	background.rect_size = self.rect_size + Vector2(10, 0)
	background.show_behind_parent = true
	
	self.add_child(background)

	
#	print("############")
#	print(self.rect_position)
#	print(self.rect_size)
#	print("############")
	

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	if Input.is_action_just_pressed("mouse_left"):
#		print(get_viewport().get_mouse_position()[0])
#		print("Rect: " + str(self.ID) + ": " + str(self.rect_position))
#		print("Mouse: " + str(get_viewport().get_mouse_position()[0]) + ", " + str(get_viewport().get_mouse_position()[1]))
		if _clicked() == true:
			get_parent().get_parent().activeButton = self.ID
			wordlist.clear()
			wordlist.rect_size[1] = self.list.size() * 20
		
			for word in self.list:
				wordlist.add_item(word)
			
			wordlist.rect_position = Vector2(self.rect_position[0], self.rect_position[1] + self.rect_size[1])
#			wordlist.rect_size[0] = self.rect_size[0]
			
func _clicked():
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
	
	