extends RichTextLabel

var count = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_levelTimer_timeout():
	count += 1
	self.clear()
	self.add_text(str(count))
	pass # replace with function body
