extends RichTextLabel

onready var progress = PROGRESS
var endSearch = false
var from = 0
var to = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if self.text != "" and endSearch == false:
		if self.get_bbcode().find("[q]", from) != -1:
			from = self.get_bbcode().find("[q]", from)
			to = self.get_bbcode().find("[/q]", from)
			progress.quote += self.get_bbcode().substr(from+3, (to-from)-3) + " "
			from = to+4
		else:
			endSearch = true
			from = 0
			to = 0
