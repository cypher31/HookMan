extends RigidBody2D

var hook_position
var hookUI
var bulletTimeOut = false
var hookHolder
var bulletLive = false
var canTeleport = false

onready var hook_scene = preload("res://Hook.tscn")

func _fixed_process(delta):
	hook_position = self.get_global_pos()
	get_parent().get_node("hookPosition").set_pos(hook_position)
	
func _on_body_enter(other):
	
	hook_position = self.get_pos()
	get_parent().get_node("hookPosition").set_pos(hook_position)

	hookHolder = get_parent().get_node("hookHolder")
	hookUI = hook_scene.instance()
	hookHolder.add_child(hookUI)
	hookUI.set_pos(self.get_pos())
	
	canTeleport = true
	bulletTimeOut = false
	bulletLive = true

	self.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_enter", self, "_on_body_enter")
	get_node("bulletLifeTimer").connect("timeout", self, "_bullet_Time_Out")
	set_fixed_process(true)
	set_process_input(true)
	get_node("bulletLifeTimer").start()
	pass

func _input(event):
	if (event.is_action_pressed("shoot")):
		get_parent().queue_free()
		
	if (event.is_action_pressed("teleport")):
		get_parent().queue_free()

func _bullet_Time_Out():
	self.queue_free()
	bulletTimeOut = true
	pass

