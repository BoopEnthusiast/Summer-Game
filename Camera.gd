extends Camera2D

@onready var mouse_dead_zone = get_viewport().size.x / 8

func _input(event):
	if event is InputEventMouseMotion:
		var _target = event.position - get_viewport().size * 0.5
		if _target.length() < mouse_dead_zone:
			position = Vector2(0,0)
		else:
			self.position = _target.normalized() * (_target.length())
