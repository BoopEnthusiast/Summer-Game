extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const JUMPS = 1
const CAMERA_DISTANCE = 0.5
const CAMERA_MAX_VELOCITY = Vector2(500, 500)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_left

@onready var coyote_timer = $CoyoteTimer
@onready var camera = $Camera

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = JUMPS
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and jumps_left >= 1:
		jumps_left -= 1
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("run_left", "run_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Move camera in direction moving
	camera.global_position = global_position + (velocity.clamp(-CAMERA_MAX_VELOCITY, CAMERA_MAX_VELOCITY) * CAMERA_DISTANCE)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
