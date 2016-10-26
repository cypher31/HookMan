extends RigidBody2D

var hook_position
var hookUI
var bulletTimeOut = false

onready var hook_scene = preload("res://Hook.tscn")

func _on_body_enter(other):
	hook_position = self.get_global_pos()
	get_parent().get_node("hookPosition").set_pos(hook_position)
	get_parent().get_node("hookPosition").destroyed = true
	
	hookUI = hook_scene.instance()
	var hookHolder = get_parent().get_node("hookHolder")
	hookHolder.add_child(hookUI)
	hookUI.set_pos(self.get_pos())
	
	bulletTimeOut = false
	
	self.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_enter", self, "_on_body_enter")
#	get_node("bulletLifeTimer").connect("timeout", self, "_bullet_Time_Out")
	set_fixed_process(true)

	bulletTimeOut = true
	
	get_node("bulletLifeTimer").start()

	pass
#
#func _bullet_Time_Out():
#	bulletTimeOut = false