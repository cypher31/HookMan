extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _input(event):
	if (event.is_action_pressed("shoot") && not event.is_echo()):
		self.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
