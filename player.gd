extends KinematicBody2D

#Player constants
#angle in degrees towards either side that player can consider floor
const FLOOR_ANGLE_TOLERANCE = 40
const GRAVITY = 2000
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const WALK_FORCE = 600
const STOP_FORCE = 1300
const JUMP_SPEED = 600
const JUMP_MAX_AIRBORNE_TIME = 0.05

const SLIDE_STOP_VELOCITY = 1.0 #one pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 #one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false
var charging = false
var pull = false

var prev_jump_pressed = false

#Shooting constants
const BULLET_SPEED = 600
const FIRE_TIME = .4
var timer = 0
var bullet
var teleportOn = false
var canTeleport = false
var destroyed = false

onready var bullet_scene = preload("res://bullet_scene.tscn")
onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

#Game Variables
var gameOver = false

func _fixed_process(delta):
	#start timer
	#timer = get_node("Timer").get_time_left()
	#create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	var stop = true
	
	if(walk_left):
		if(velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif(walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
				
	if(stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if(vlen < 0):
			vlen = 0
		
		velocity.x = vlen * vsign
	
	#integrate forces to velocity
	velocity += force * delta
	
	#integrate velocity into motion and move
	var motion = velocity * delta
	
	if(pull == true):
		self.set_pos(bullet.get_node("hookPosition").get_pos())
		pull = false
		
	#move and consume motion
	move(motion)
	
	var floor_velocity = Vector2()
	
	if(is_colliding()):
		var n = get_collision_normal()
		
		#tile collision logic
		#for this to work the tile actually needs to be touched, not the collision polygon attached to the tile
		#also this has to come before the "slide" logic below (I think...)
		var collidingWith = get_collision_pos()
		var tile = get_parent().get_node("TileMap").get_cellv(get_parent().get_node("TileMap").world_to_map(collidingWith))
		if(tile == 2):
			self.queue_free()
			gameOver = true
		
		if(rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			#if angle to the up vectors is < agnle tolerance
			#char is on the floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
			
			
		if(on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		
		else:
			#for every other case of motion, our motion was interrupted
			#try to complete the motion by sliding by the normal
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			#then move
			move(motion)
	
	if(floor_velocity != Vector2()):
		#if floor moves, move with floor
		move(floor_velocity * delta)
		
	if(jumping and velocity.y > 0):
		#if falling, no longer jumping
		jumping = false
	
	if(on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		# jump must also be allowed to happen if the character left the floor a little bit ago
		#maves control move snappy
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	#Shooting
	#mouse position
	offset = -get_viewport().get_canvas_transform().o * get_node("Camera2D").get_zoom() # Get the offset
	relative_mouse_pos = get_viewport().get_mouse_pos() * get_node("Camera2D").get_zoom() + offset
	#have gun look at mouse location
	get_node("playerSprite").look_at(relative_mouse_pos)
	#move crosshair to mouse position
	



func _input(event):

	if (event.is_action_pressed("shoot") && not event.is_echo()):

		bullet = bullet_scene.instance()
		var playerPosition = get_node("playerSprite").get_pos()
		var bulletSpawnPoint = get_node("playerSprite/bulletSpawnPoint").get_global_pos() #to have objects move independently attach to a "node" (simplest node possible) then instance at that nodes position
		var bulletHolder = get_node("bulletsHolder")
		bulletHolder.add_child(bullet)
		bullet.set_pos(bulletSpawnPoint)
		bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(BULLET_SPEED, 0).rotated(get_node("playerSprite").get_rot() - deg2rad(90)))
		bullet.get_node("RigidBody2D/Sprite").set_rot(deg2rad(90))
		bullet.look_at(relative_mouse_pos)
		print(get_tree().get_nodes_in_group("bullet").size())
		teleportOn = true

	if (event.is_action_pressed("teleport") && not event.is_echo() && teleportOn == true):
		pull = true
		teleportOn = false
		canTeleport = false
		bullet.queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	pass



