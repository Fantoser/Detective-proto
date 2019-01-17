extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var ID = 0
var type = ""
var list = []
var attributes = []
onready var FollowButt = get_node("../../FollowButt")
onready var wordlist = get_node("../wordlist")


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _pressed():
	if type == "cluebutt":

		FollowButt.rect_size = self.rect_size
		FollowButt.text = self.text
		FollowButt.list = self.list
		FollowButt.rect_position = self.rect_position
		FollowButt.follow = true
		FollowButt.distdiff = get_viewport().get_mouse_position() - self.rect_position
		
	if type == "listbutt":
		get_parent().get_parent().activeButton = self.ID
		wordlist.clear()
		wordlist.rect_size[1] = self.list.size() * 20
		
		for word in self.list:
			wordlist.add_item(word)
		
		wordlist.rect_position = Vector2(self.rect_position[0], self.rect_position[1] + self.rect_size[1])
		wordlist.rect_size[0] = self.rect_size[0]
#	print("Mouse pos: " + str(get_viewport().get_mouse_position()))