extends RigidBody2D

var hook_position
var hookUI
<<<<<<< HEAD
var bulletTimeOut = false
var hookHolder
var bulletLive = false
=======
>>>>>>> parent of ea019b2... Nothing really

#onready var hook_scene = preload("res://Hook.tscn")

func _on_body_enter(other):
	
	hook_position = self.get_global_pos()
	get_parent().get_node("hookPosition").set_pos(hook_position)
	
#	hookUI = hook_scene.instance()
#	hookHolder = get_parent().get_node("hookHolder")
#	hookHolder.add_child(hookUI)
#	hookUI.set_pos(self.get_pos())

	get_parent().get_node("hookPosition").isLive = true
	
<<<<<<< HEAD
	bulletTimeOut = false
	bulletLive = true
	
=======
>>>>>>> parent of ea019b2... Nothing really
	self.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_enter", self, "_on_body_enter")
<<<<<<< HEAD
	get_node("bulletLifeTimer").connect("timeout", self, "_bullet_Time_Out")
	set_fixed_process(true)
	
	get_node("bulletLifeTimer").start()

	pass

func _bullet_Time_Out():
	self.queue_free()
	bulletTimeOut = true
=======
	set_fixed_process(true)

	pass
>>>>>>> parent of ea019b2... Nothing really
