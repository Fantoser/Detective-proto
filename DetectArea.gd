extends Spatial

export var type = "clue"
export var clue_word = ""
export var dialogue = ""
export var starter = "first"
export var description = ""
export var attributes = []
export var presentlist = []
var list = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	list = {word = clue_word, desc = description, attributes = []}
	
	for attribute in attributes:
		list["attributes"].append(attribute)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
