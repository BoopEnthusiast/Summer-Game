extends CharacterBody2D

const HALF_PI = PI / 2
const SPEED = 500.0
const JUMP_VELOCITY = -1400.0
const JUMPS = 1
const CAMERA_DISTANCE = 0.3
const CAMERA_MAX_VELOCITY = Vector2(500, 500)
const WALL_SLIDE_SPEED = 150
const CHAIN_PULL = 105
const MAX_SPEED = 5000
const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground
const GRAVITY = 70				# Gravity applied every second
const PUSH_FORCE = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jumps_left = 0
var chain_velocity := Vector2(0,0)

@onready var coyote_timer = $CoyoteTimer
@onready var camera = $Camera
@onready var grapple_hook = $Hook
@onready var sprite = $Sprite

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			self.get_global_transform_with_canvas()
			grapple_hook.shoot(event.position - self.get_global_transform_with_canvas().get_origin())
		else:
			# We released the mouse -> release()
			grapple_hook.release()


func _physics_process(_delta):
	# Walking
	var walk = Input.get_axis("run_left", "run_right") * SPEED
	
	if Input.get_axis("run_left", "run_right") < 0:
		sprite.flip_h = true
	elif Input.get_axis("run_left", "run_right") > 0:
		sprite.flip_h = false
	
	if not is_on_floor():
		sprite.play("air")
	elif Input.get_axis("run_left", "run_right") != 0:
		sprite.play("run")
	else:
		sprite.play("default")
	
	#Gravity
	if not is_on_floor():
		velocity.y += GRAVITY
	
	# Grapple hook 
	if grapple_hook.hooked:
		chain_velocity = to_local(grapple_hook.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different direction than the chain is pulling reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity
	
	# Save for coyote timer check
	var was_touching = is_on_floor() or is_on_wall()
	
	velocity.x += walk
	if move_and_slide():
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_force(col.get_normal() * -PUSH_FORCE)
	sprite.material.set_shader_parameter("direction", velocity * 0.001)
	sprite.rotation = get_angle_to(to_global(velocity.normalized())) - HALF_PI
	while sprite.rotation < -HALF_PI:
		sprite.rotation += PI
	while sprite.rotation > HALF_PI:
		sprite.rotation -= PI
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
	
	if is_on_floor():
		if Input.is_action_pressed("run_left") and Input.is_action_pressed("run_right"):
			sprite.rotation_degrees -= 90
		elif Input.is_action_pressed("run_left"):
			sprite.rotation_degrees += 90
		elif Input.is_action_pressed("run_right"):
			sprite.rotation_degrees -= 90
		else:
			sprite.rotation_degrees -= 90
			print("helloooo")
	elif is_on_wall():
		if Input.is_action_pressed("run_left"):
			sprite.rotation_degrees -= 45
		if Input.is_action_pressed("run_right"):
			sprite.rotation_degrees += 45
