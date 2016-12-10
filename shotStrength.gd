extends Control

var lineStartPosition
var lineEndPosition

func _input(event):
	
	if(event.is_action_pressed("shoot")):
		lineStartPosition = get_parent().get_parent().get_node("crossHair/crossHairSprite").get_pos()

func _draw():
	
	if(get_parent().drawLine == true):
		draw_line(lineStartPosition, lineEndPosition, Color(255,0,0), 2)
	pass
	
func _process(delta):
	
	if(get_parent().drawLine == true):
		lineEndPosition = get_parent().get_parent().get_node("crossHair/crossHairSprite").get_pos()
	update()

func _ready():
	set_process(true)
	set_process_input(true)

	
