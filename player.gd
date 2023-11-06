extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const JUMPS = 1
const CAMERA_DISTANCE = 0.3
const CAMERA_MAX_VELOCITY = Vector2(500, 500)
const WALL_SLIDE_SPEED = 50
const CHAIN_PULL = 70

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_left = 0
var chain_velocity := Vector2(0,0)

@onready var coyote_timer = $CoyoteTimer
@onready var camera = $Camera
@onready var grapple_hook = $Hook

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			grapple_hook.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release()
			grapple_hook.release()

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump
	if is_on_floor() or is_on_wall():
		jumps_left = JUMPS
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and jumps_left >= 1:
		jumps_left -= 1
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("run_left", "run_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Move camera in direction moving
	#camera.global_position = global_position + (velocity.clamp(-CAMERA_MAX_VELOCITY, CAMERA_MAX_VELOCITY) * CAMERA_DISTANCE)
	
	# Grapple hook
	if grapple_hook.hooked:
		chain_velocity = to_local(grapple_hook.tip).normalized() * CHAIN_PULL
		chain_velocity.x *= 5
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.25
		else:
			# Pulling up is stronger
			chain_velocity.y *= 0.6
		if sign(chain_velocity.x) != Input.get_axis("run_left", "run_right"):
			# if we are trying to walk in a different direction than the chain is pulling reduce its pull
			chain_velocity.x *= 0.65
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	
	print(velocity)
	print(chain_velocity)
	velocity += chain_velocity
	print(velocity)
	
	# Slide down wall
	if is_on_wall_only() and velocity.y > 0:
		velocity.y = WALL_SLIDE_SPEED
	
	# Save for coyote timer check
	var was_touching = is_on_floor() or is_on_wall()
	
	move_and_slide()
	
	# Start coyote timer
	if was_touching and not (is_on_floor() or is_on_wall()):
		coyote_timer.start()

