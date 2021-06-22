extends KinematicBody2D

const FRICTION: float = 20.0
const DAMAGE: int = 15
const KNOCKBACK_STRENGTH: int = 0

var MAX_SPEED: float = 100.0
var ACCELERATION: float = 100.0

var velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2(1, 0)

var started: bool = false setget set_start

func _physics_process(delta):
	velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	
	if velocity.x < 0:
		get_node("Sprite").frame = 1
	else:
		get_node("Sprite").frame = 0

func _on_Timer_timeout():
	if started:
		dir = global_position.direction_to(get_parent().get_node("Boat").global_position)
	else:
		dir = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()

func set_start(passed_value: bool):
	started = passed_value
	if started:
		MAX_SPEED = 200.0
		ACCELERATION = 200.0
	else:
		MAX_SPEED = 100.0
		ACCELERATION = 100.0

func get_damage_info() -> Dictionary:
	var damage_info: Dictionary = {
		"damage" : DAMAGE,
		"reference" : self,
		"knockback" : dir * KNOCKBACK_STRENGTH,
		"type" : "normal"
	}
	return damage_info
