extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _input(event):
	if (event.is_action_pressed("shoot")):
		print("working")
		self.queue_free()

func _ready():
	set_process_input(true)
	pass
