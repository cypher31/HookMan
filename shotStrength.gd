extends Control

var lineStartPosition
var lineEndPosition

func _input(event):
	
	if(event.is_action_pressed("shoot")):
		lineStartPosition = get_local_mouse_pos()

func _draw():
	
	if(get_parent().drawLine == true):
		if(abs(sqrt(lineStartPosition.x*lineStartPosition.x + lineStartPosition.y*lineStartPosition.y) - sqrt(get_local_mouse_pos().x*get_local_mouse_pos().x + get_local_mouse_pos().y*get_local_mouse_pos().y)) / 100 > 4.00):
			draw_line(lineStartPosition, lineEndPosition, Color(255,0,0), 2)
		
		if(abs(sqrt(lineStartPosition.x*lineStartPosition.x + lineStartPosition.y*lineStartPosition.y) - sqrt(get_local_mouse_pos().x*get_local_mouse_pos().x + get_local_mouse_pos().y*get_local_mouse_pos().y)) / 100 < 2.00):
			draw_line(lineStartPosition, lineEndPosition, Color(0,0,255), 2)
		
		if(abs(sqrt(lineStartPosition.x*lineStartPosition.x + lineStartPosition.y*lineStartPosition.y) - sqrt(get_local_mouse_pos().x*get_local_mouse_pos().x + get_local_mouse_pos().y*get_local_mouse_pos().y)) / 100 < 4.00 && abs(sqrt(lineStartPosition.x*lineStartPosition.x + lineStartPosition.y*lineStartPosition.y) - sqrt(get_local_mouse_pos().x*get_local_mouse_pos().x + get_local_mouse_pos().y*get_local_mouse_pos().y)) / 100 > 2.00):
			draw_line(lineStartPosition, lineEndPosition, Color(0,255,0), 2)
	pass
	
func _process(delta):
	
	if(get_parent().drawLine == true):
		lineEndPosition = get_local_mouse_pos()
	update()

func _ready():
	set_process(true)
	set_process_input(true)

	
