extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

func _fixed_process(delta):
	#mouse position
#	offset = -get_viewport().get_canvas_transform().o # Get the offset
	relative_mouse_pos = get_local_mouse_pos()
	get_node("crossHairSprite").set_pos(relative_mouse_pos)
	#move crosshair to mouse position
	
func _ready():
	set_fixed_process(true)
	pass


