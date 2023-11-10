extends RigidBody2D
class_name Hook

const SPEED = 50	# The speed with which the chain moves

@onready var player = $".."

var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
var flying = false	# Whether the chain is moving through the air
var hooked = false	# Whether the chain has connected to a wall

func _ready():
	add_user_signal("object_hooked", [{"name": "object_hit", "type": "TYPE_KINEMATIC_COLLISION_2D"}])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	global_position = tip
	if flying:
		var collider = move_and_collide(direction * SPEED)
		if collider and collider.get_collider() != player:
			hooked = true
			flying = false
			emit_signal("object_hooked", collider)
	tip = global_position

func shoot(dir: Vector2):
	direction = dir.normalized()
	flying = true
	tip = player.global_position

func release():
	hooked = false
	flying = false
