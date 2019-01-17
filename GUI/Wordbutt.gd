extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ID = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("mouse_left"):
		if _clicked() == true:
			get_parent().get_parent()._remove_text(ID)

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