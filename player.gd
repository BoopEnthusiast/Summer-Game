extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -1000.0
const JUMPS = 1
const CAMERA_DISTANCE = 0.3
const CAMERA_MAX_VELOCITY = Vector2(500, 500)
const WALL_SLIDE_SPEED = 150
const CHAIN_PULL = 105
const MAX_SPEED = 2000
const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground

const GRAVITY = 40				# Gravity applied every second

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_left = 0
var chain_velocity := Vector2(0,0)

@onready var coyote_timer = $CoyoteTimer
@onready var camera = $Camera
@onready var grapple_hook = $Hook
@onready var sprite = $AnimatedSprite2D

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			self.get_global_transform_with_canvas()
			grapple_hook.shoot(event.position - self.get_global_transform_with_canvas().get_origin())
		else:
			# We released the mouse -> release()
			grapple_hook.release()


func _physics_process(delta):
	# Walking
	var walk = Input.get_axis("run_left", "run_right") * SPEED
	
	if Input.is_action_pressed("run_right"):
		sprite.flip_h = false
	elif Input.is_action_pressed("run_left"):
		sprite.flip_h = true
	
	if not is_on_floor():
		sprite.play("air")
	elif Input.is_action_pressed("run_right"):
		sprite.play("run")
	elif Input.is_action_pressed("run_left"):
		sprite.play("run")
	else:
		sprite.play("default")
	
	#Gravity
	velocity.y += GRAVITY
	
	# Grapple hook 
	if grapple_hook.hooked:
		chain_velocity = to_local(grapple_hook.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.25
		else:
			# Pulling up is stronger
			chain_velocity.y *= 0.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different direction than the chain is pulling reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity
	
	# Move camera in direction moving
	#camera.global_position = global_position + (velocity.clamp(-CAMERA_MAX_VELOCITY, CAMERA_MAX_VELOCITY) * CAMERA_DISTANCE)
	
	# Slide down wall
	#if is_on_wall_only() and velocity.y > 0:
	#	velocity.y = WALL_SLIDE_SPEED
	
	# Save for coyote timer check
	var was_touching = is_on_floor() or is_on_wall()
	
	velocity.x += walk
	move_and_slide()
	if not is_on_wall():
		velocity.x -= walk
	
	# Start coyote timer
	if was_touching and not (is_on_floor() or is_on_wall()):
		coyote_timer.start()
	
	# Manage friction
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	var grounded = is_on_floor() 
	
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if not grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
	
	if is_on_wall_only():
		velocity.y *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
	
	# Handle Jump
	if is_on_floor() or is_on_wall():
		jumps_left = JUMPS
	
	if Input.is_action_just_pressed("jump"): 
		if is_on_floor() or not coyote_timer.is_stopped():
			velocity.y = JUMP_VELOCITY
		elif jumps_left >= 1:
			jumps_left -= 1
			velocity.y = JUMP_VELOCITY
