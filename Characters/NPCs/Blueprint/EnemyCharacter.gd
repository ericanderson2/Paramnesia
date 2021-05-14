extends KinematicBody2D

class_name EnemyCharacter

const floating_numbers = preload("res://Effects/DamageNumbers/FriendlyNumbers.tscn")

onready var animation_player = get_node("AnimationPlayer")
onready var health_bar = get_node("HealthBar")
onready var hurtbox = get_node("Hurtbox")
onready var sprite = get_node("Sprite")
onready var hit_timer = get_node("HitEffect")
onready var animationPlayer = get_node("AnimationPlayer")
onready var animationTree = get_node("AnimationTree")
onready var animationState = animationTree.get("parameters/playback")
onready var focus = get_node("Focus")
onready var attack_timer = get_node("AttackCooldown")
onready var debug_text = get_node("DebugText")
onready var path_line = get_node("PathLine")

enum {
	WANDER,
	PATH,
	GUARD,
	STAY
}

enum {
	WALK,
	ATTACK,
	IDLE
}

export var max_health: int = 100
export var damage: int = 10
export var MAX_SPEED: float = 50.0
export var ACCELERATION: float = 500.0
export var AGRO_RANGE: float = 200.0
export var LEAVE_AGRO_RANGE: float = 300.0
export var ATTACK_RANGE: float = 20.0
export var FOCUS_TIME: float = 2.0
export var ATTACK_COOLDOWN: float = 2.5
export var KNOCKBACK_STRENGTH: int = 200
export var DEBUG_CAN_TARGET: bool = true
export var path_target: Vector2 = Vector2.ZERO

var health setget set_health
var MAX_WANDER_DISTANCE: float = 20.0
var dir: Vector2 = Vector2(1, 0)
var state = WALK
export var goal = PATH
var velocity: Vector2 = Vector2.ZERO
var spawn_location
var agro: bool = false
var can_attack: bool = true
var nearest_enemy
var knockback: Vector2 = Vector2.ZERO
var knockback_vector: Vector2 = Vector2.ZERO
var pathfinding

func _ready():
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	focus.wait_time = FOCUS_TIME
	attack_timer.wait_time = ATTACK_COOLDOWN
	spawn_location = global_position
	sprite.set_material(sprite.get_material().duplicate())
	animationTree.active = true
	animationState.start("Idle")
	set_direction(dir)
	set_physics_process(false)

func initialize(passed_pathfinding):
	pathfinding = passed_pathfinding
	set_physics_process(true)

func _physics_process(delta):
	set_direction(dir)
	if agro:
		agro_state()
		get_node("StateIndicator").frame = 2
	else:
		path_line.visible = false
		if goal == GUARD:
			get_node("StateIndicator").frame = 1
		else:
			get_node("StateIndicator").frame = 0
	match state:
		WALK:
			walk(delta)
		IDLE:
			idle()
		ATTACK:
			attack()
	knockback_vector = dir
	knockback = knockback.move_toward(Vector2.ZERO, delta * 200)
	knockback = move_and_slide(knockback)
	if DEBUG_CAN_TARGET:
		check_for_enemies()
	update_debug_text()

func walk(delta):
	if goal == GUARD or agro:
		animationState.travel("WalkWeapon")
	elif goal == PATH:
		start_new_path(path_target)
		animationState.travel("Walk")
	else:
		animationState.travel("Walk")
	velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	if goal == PATH:
		if global_position.distance_to(path_target) < 10:
			goal = STAY
			path_line.visible = false
			state = IDLE

func start_new_path(target: Vector2) -> bool:
	var path = pathfinding.get_new_path(global_position, target, true)
	if path.size() > 1:
		update_path_line(path)
		path.pop_front()
		target = path.pop_front()
		dir = global_position.direction_to(target)
		set_direction(dir)
		return true
	else:
		return false

func agro_state():
	if is_instance_valid(nearest_enemy):
		start_new_path(nearest_enemy.global_position)
		if global_position.distance_to(nearest_enemy.global_position) < ATTACK_RANGE:
			if can_attack:
				state = ATTACK
			else:
				state = IDLE
		else:
			state = WALK

func idle():
	if goal == GUARD or agro:
		animationState.travel("IdleWeapon")
	else:
		animationState.travel("Idle")

func attack():
	animationState.travel("Attack")

func choose_new_action():
	if goal == GUARD:
		if randi() % 2 == 0:
			state = WALK
		else:
			state = IDLE
		var dir_x = randi() % 10 - 5
		var dir_y = randi() % 10 - 5
		dir = Vector2(dir_x, dir_y).normalized()
		if global_position.distance_to(spawn_location) > MAX_WANDER_DISTANCE:
			dir = global_position.direction_to(spawn_location)
			state = WALK
	elif goal == WANDER:
		if randi() % 4 == 0:
			state = IDLE
		else:
			state = WALK
		var dir_x = randi() % 10 - 5
		var dir_y = randi() % 10 - 5
		dir = Vector2(dir_x, dir_y).normalized()
	elif goal == PATH:
		state = WALK

func check_for_enemies():
	agro = false
	var enemies = get_tree().get_nodes_in_group("FriendlyArmy")
	var smallest_distance = 1000
	for enemy in enemies:
		var enemy_distance = global_position.distance_to(enemy.global_position)
		if not agro:
			if enemy_distance < AGRO_RANGE and pathfinding.get_new_path(global_position, enemy.global_position, true).size() > 0:
				agro = true
				if enemy_distance < smallest_distance:
					nearest_enemy = enemy
					smallest_distance = enemy_distance
		else:
			if enemy_distance < LEAVE_AGRO_RANGE and pathfinding.get_new_path(global_position, enemy.global_position, true).size() > 0:
				agro = true
				if enemy_distance < smallest_distance:
					nearest_enemy = enemy
					smallest_distance = enemy_distance
	
		

func set_direction(direction):
	animationTree.set("parameters/Idle/blend_position", direction)
	animationTree.set("parameters/IdleWeapon/blend_position", direction)
	animationTree.set("parameters/Walk/blend_position", direction)
	animationTree.set("parameters/WalkWeapon/blend_position", direction)
	animationTree.set("parameters/Attack/blend_position", direction)

func dead():
	var splatter = load("res://Effects/Disappear/Disappear.tscn").instance()
	add_child(splatter)
	set_physics_process(false)
	animation_player.stop()

func _on_Hurtbox_area_entered(area):
	if area.get_parent().has_method("resolve_hit"):
		area.get_parent().resolve_hit()
	if hurtbox.invincible:
		return
	var area_damage = 0
	if area.get_parent().has_method("get_damage"):
		area_damage = area.get_parent().get_damage()
	if area.get_parent().has_method("get_knockback"):
		knockback = area.get_parent().get_knockback()
	sprite.get_material().set_shader_param("highlight", true)
	hit_timer.start()
	set_health(health - area_damage)
	
	var numbers = floating_numbers.instance()
	numbers.text = str(area_damage)
	add_child(numbers)
	
	hurtbox.start_invicibility(0.4)

func _on_HitEffect_timeout():
	sprite.get_material().set_shader_param("highlight", false)

func _on_Focus_timeout():
	if not agro:
		choose_new_action()

func set_health(new_health):
	health = new_health
	health_bar.value = health
	health_bar.show()
	health_bar.get_node("HealthBarTimer").start(15)
	if health <= 0:
		dead()

func get_damage():
	return damage

func get_knockback():
	return knockback_vector * KNOCKBACK_STRENGTH

func update_debug_text():
	var debug_state = ""
	var debug_goal = ""
	
	match state:
		0:
			debug_state = "WALK"
		1:
			debug_state = "ATTACK"
		2:
			debug_state = "IDLE"

	match goal:
		0:
			debug_goal = "WANDER"
		1:
			debug_goal = "PATH"
		2:
			debug_goal = "GUARD"
	var text = "State: " + debug_state + "\nGoal: " + debug_goal + "\nAgro: " + str(agro)
	debug_text.text = text
	
	if agro and Global.debug_mode:
		get_node("EndPoint").visible = true
		get_node("Target").visible = true
	else:
		get_node("EndPoint").visible = false
		get_node("Target").visible = false


func _on_HealthBarTimer_timeout():
	health_bar.hide()

func _on_AttackCooldown_timeout():
	can_attack = true

func update_path_line(points: Array):
	if Global.debug_mode:
		path_line.visible = true
		var local_points: Array = []
		for point in points:
			local_points.append(point - global_position)
		local_points[0] = Vector2.ZERO
	
		path_line.points = local_points
		if local_points.size() <= 2:
			path_line.visible = false
		
		if local_points.size() > 0:
			get_node("EndPoint").rect_position = local_points[local_points.size() - 1] - (get_node("EndPoint").rect_size / 2)
		get_node("Target").rect_global_position = nearest_enemy.global_position - (get_node("Target").rect_size / 2)
	else:
		path_line.visible = false
		get_node("EndPoint").visible = false
		get_node("Target").visible = false
