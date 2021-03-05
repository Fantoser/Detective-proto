extends ItemList


var listH


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	listH = get_parent().rect_position.y + self.rect_position.y + self.rect_size.y

#	if self.rect_position.x < get_parent().rect_position.x and self.set_auto_height(false):
#		print("E")
#		self.set_auto_height(true)
#		self.rect_size[1] = 0

	if listH > get_viewport().size.y+1:
		self.set_auto_height(false)
		self.rect_size[1] -= listH - get_viewport().size.y

	if self.rect_position.x < 0:
		self.rect_size[1] = 1
		self.set_auto_height(true)
