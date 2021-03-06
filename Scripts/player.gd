extends KinematicBody2D

#Player constants
#angle in degrees towards either side that player can consider floor
const FLOOR_ANGLE_TOLERANCE = 40
const GRAVITY = 2000
const WALK_MIN_SPEED = 200
const WALK_MAX_SPEED = 1000
const WALK_FORCE = 2000
const FLY_MIN_SPEED = 200
const FLY_MAX_SPEED = 1000
const FLY_FORCE = 2000
const BOOST_FORCE = Vector2(500,0)
const STOP_FORCE = 1000
const JUMP_SPEED = 1000
const JUMP_MAX_AIRBORNE_TIME = 10

const SLIDE_STOP_VELOCITY = 1.0 #one pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 #one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false
var charging = false
var pull = false
var walk_left
var walk_right
var force
var motion
var fly

var prev_jump_pressed = false

#Shooting constants
const BULLET_SPEED = 3000
const FIRE_TIME = .4
var shotCharge = 1
var canShoot = true
var mousePositionStart
var mousePositionCurrent
var mousePositionEnd
var playerCurrentRotation
var shotAngle
var mouseDelta
var drawLine = false
var timer = 0
var bullet
var teleportOn = false
var canTeleport = false
var destroyed = false

onready var bullet_scene = preload("res://Scenes/bullet_scene.tscn")
onready var offset = Vector2(0, 0)
onready var relative_mouse_pos = Vector2(0, 0)

#Game Variables
var gameOver = false

func _fixed_process(delta):
	force = Vector2(0, GRAVITY)
	
	walk_left = Input.is_action_pressed("move_left")
	walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	fly = Input.is_action_pressed("fly")
	
	var stop = true
	
	if(walk_left):
		if(velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif(walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
				
	elif(fly):
		if (velocity.y >= -FLY_MIN_SPEED and velocity.y < FLY_MAX_SPEED):
			force.y += FLY_FORCE
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
	motion = velocity * delta
		
	#move and consume motion
	move(motion)
	
	var floor_velocity = Vector2()
	
	if(self.get_pos().y > 2000):
		get_tree().reload_current_scene()

	
	if(is_colliding()):
		var n = get_collision_normal()
		
		#tile collision logic
		#for this to work the tile actually needs to be touched, not the collision polygon attached to the tile
		#also this has to come before the "slide" logic below (I think...)
		var collidingWith = get_collider().get_owner().is_in_group("lava")
		print(collidingWith)
#		var tile = get_tree().get_current_scene().get_node("TileMap").get_cellv(get_tree().get_current_scene().get_node("TileMap").world_to_map(collidingWith))
		if(get_collider().get_owner().is_in_group("lava")):
			get_tree().reload_current_scene()
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
#	get_node("playerSprite").look_at(relative_mouse_pos)
	get_node("playerSprite/bulletSpawnPoint").look_at(relative_mouse_pos)
	#have gun look at mouse location
	
func _input(event):

	if (event.is_action_pressed("shoot") && not event.is_echo() && canShoot == true):
		get_node("timerHolder/shootTimer").start()
		mousePositionStart = get_viewport().get_mouse_pos()
		playerCurrentRotation = get_node("playerSprite/bulletSpawnPoint").get_rot()
#		mouseDelta = mousePositionStart - get_node("playerSprite/bulletSpawnPoint").get_pos()
#		shotAngle = atan2(mouseDelta.x, mouseDelta.y)
		
		bullet = bullet_scene.instance()
		var playerPosition = get_node("playerSprite").get_pos()
		var bulletSpawnPoint = get_node("playerSprite/bulletSpawnPoint").get_global_pos() #to have objects move independently attach to a "node" (simplest node possible) then instance at that nodes position
		var bulletHolder = get_node("bulletsHolder")
		bulletHolder.add_child(bullet)
		bullet.set_pos(bulletSpawnPoint)
		bullet.get_node("RigidBody2D").set_linear_velocity(Vector2(BULLET_SPEED, 0).rotated(playerCurrentRotation - deg2rad(90)))
		bullet.get_node("RigidBody2D").set_rot(deg2rad(270))
		bullet.look_at(relative_mouse_pos)
		canShoot = false
#		teleportOn = true

#	if (event.is_action_pressed("teleport") && not event.is_echo() && teleportOn == true):
#		self.set_global_pos(bullet.get_node("hookPosition").get_pos())
#		teleportOn = false
#		canTeleport = false
#		bullet.queue_free()
	
	if(Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	
	if(event.is_action_pressed("move_left")):
		if(get_node("timerHolder/doubleTapTimer").is_processing()):
			_double_tap_left()
		else: 
			get_node("timerHolder/doubleTapTimer").start()

	if(event.is_action_pressed("move_right")):
		if(get_node("timerHolder/doubleTapTimer").is_processing()):
			_double_tap_right()
		else: 
			get_node("timerHolder/doubleTapTimer").start()

	if(event.is_action("fly")):
		if (velocity.y >= -FLY_MIN_SPEED and velocity.y < FLY_MAX_SPEED):
			force.y += FLY_FORCE
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	pass

func _on_shootTimer_timeout():
	canShoot = true
	pass 

func _double_tap_left():
	motion -= BOOST_FORCE
	#integrate velocity into motion and move
	#move and consume motion
	move(motion)
	velocity.x = 0
	pass
	
func _double_tap_right():
	motion += BOOST_FORCE
	#integrate velocity into motion and move
	#move and consume motion
	move(motion)
	velocity.x = 0
	pass
