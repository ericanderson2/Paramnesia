extends KinematicBody2D

const MAX_SPEED: float = 100.0
const ACCELERATION: float = 100.0
const FRICTION: float = 20.0

var velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2(1, 0)

func _physics_process(delta):
	velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)

func _on_Timer_timeout():
	dir = global_position.direction_to(get_parent().get_node("Boat").global_position)
