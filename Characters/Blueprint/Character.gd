extends KinematicBody2D

class_name Character

const VALID_OUTLINE_COLOR: Color = Color("#ffffff")
const INVALID_OUTLINE_COLOR: Color = Color("#0081ff")
const disappear_effect = preload("res://Effects/Disappear/Disappear.tscn")

onready var health_bar = get_node("HealthBar")
onready var hurtbox = get_node("Hurtbox")
onready var sprite = get_node("Sprite")
onready var hit_timer = get_node("HitEffect")
onready var invincibility_timer = get_node("InvincibilityTimer")
onready var tween = get_node("Tween")
onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")

export var MAX_HEALTH: int = 100
export var MAX_SPEED: int = 100
export var MAX_SPEED_RUNNING: int = 100
export var ACCELERATION: int = 500
export var FRICTION: int = 400
export var INVINCIBILITY_TIME: float = 0.4
export var FLEE_ON_HIT: bool = false
export var FLEE_ON_LOW_HEALTH: bool = false
export var FLEE_HEALTH_PERCENT: float = 0.25
export var CAN_HOVER: bool = false # whether or not mousing over the character will make something happen. For instance, displaying the level above the character.
export var CAN_INTERACT: bool = false # whether or not the character can be right clicked on to do something. This will enable an outline when the character is moused over.
export var INTERACT_DISTANCE: int = 50 # the distance from which the player is able to right click on the character, in pixels.
export var DAMAGE: int = 20
export var VIEW_DISTANCE: int = 100
export var KNOCKBACK_STRENGTH: float = 50.0

var health: int setget set_health
var dir: Vector2 = Vector2(1, 0)
var velocity: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO
var invincible: bool = false
var has_focus: bool = false
var is_pathing: bool = false
var path_target: Vector2 = Vector2.ZERO
var current_path: Array = []
var pathfinding_controller = null
var frames_elapsed: int = 0
var fleeing: bool = false
var running: bool = false
var last_damage_source: Object = null
var current_threat


func _ready():
	animation_tree.active = true
	set_direction(dir)
	animation_state.start("Idle")
	
	health_bar.max_value = MAX_HEALTH
	health = MAX_HEALTH
	health_bar.value = health
	health_bar.hide()
	
	sprite.set_material(sprite.get_material().duplicate())
	invincibility_timer.wait_time = INVINCIBILITY_TIME
	
	get_node("ViewDistance/CollisionShape2D").shape.radius = VIEW_DISTANCE
	
	extra_init()

func _physics_process(delta):
	frames_elapsed += 1
	if frames_elapsed > 30:
		frames_elapsed = 0
		if is_pathing:
			is_pathing = start_path(path_target)
	running = false
	if fleeing:
		running = true
		animation_state.travel("Run")
		flee_logic(delta)
	else:
		state_logic(delta)
	apply_knockback(delta)
	update_debug_info(Global.debug_show_paths)

func move(delta):
	if running:
		velocity = velocity.move_toward(dir * MAX_SPEED_RUNNING, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)

func apply_knockback(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * 200)
	knockback = move_and_slide(knockback)

# starts a new path from character to target. if the path is valid, returns true. otherwise, returns false
func start_path(target: Vector2) -> bool:
	if pathfinding_controller == null:
		pathfinding_controller = get_tree().get_current_scene().pathfinding_controller
		if pathfinding_controller == null:
			return false
	if pathfinding_controller.is_valid_path(self.global_position, target, true):
		is_pathing = true
		current_path = pathfinding_controller.get_new_path(self.global_position, target, true)
		if current_path.size() > 0:
			return true
	return false

func is_valid_path(target: Vector2, allow_approximation: bool = true, search_distance: int = 2) -> bool:
	if pathfinding_controller == null:
		pathfinding_controller = get_tree().get_current_scene().pathfinding_controller
		if pathfinding_controller == null:
			return false
	return pathfinding_controller.is_valid_path(self.global_position, target, allow_approximation, search_distance)

func follow_current_path(delta):
	if current_path.size() > 0:
		var next_point: Vector2 = current_path[0]
		if self.global_position.distance_to(next_point) < 16:
			current_path.pop_front()
			if current_path.size() < 1:
				is_pathing = false
				finished_path()
				return
			next_point = current_path[0]
		dir = self.global_position.direction_to(next_point)
		set_direction(dir)
		move(delta)

func flee_logic(delta):
	if not is_pathing:
		path_target = global_position - 64 * global_position.direction_to(last_damage_source.global_position) + Vector2(rand_range(-16, 16), rand_range(-16, 16))
		is_pathing = start_path(path_target)
	follow_current_path(delta)

func _on_HitEffect_timeout():
	sprite.get_material().set_shader_param("highlight", false)

func set_health(new_health):
	health = new_health
	tween.interpolate_property(health_bar, "value", health_bar.value, health, 0.3, Tween.TRANS_LINEAR)
	tween.start()
	health_bar.show()
	health_bar.get_node("VisibilityTimer").start(15)
	if health <= 0:
		dead()

func _on_Hurtbox_area_entered(area):
	if area.get_parent().has_method("resolve_hit"):
		area.get_parent().resolve_hit()

	if invincible or not area.get_parent().has_method("get_damage_info"):
		return
	
	var damage_info: Dictionary = area.get_parent().get_damage_info()
	var damage: int = damage_info["damage"]
	var reference: Object = damage_info["reference"]
	if reference == self:
		return
	
	knockback = damage_info["knockback"]
	
	sprite.get_material().set_shader_param("highlight", true)
	hit_timer.start()
	set_health(health - damage)
	
	# show hit numbers above character
	floating_damage_numbers(damage)
	
	if damage >= 1:
		invincible = true
		invincibility_timer.start()
	
	if FLEE_ON_HIT:
		fleeing = true
		is_pathing = false
		get_node("FleeTimer").start(3.0)
		last_damage_source = reference
	
	damage_taken(damage_info)

func _on_InteractArea_mouse_entered():
	if CAN_HOVER:
		try_to_grab_focus()

func _on_InteractArea_mouse_exited():
	if has_focus:
		has_focus = false
		Global.num_interacted_with = 0
	sprite.get_material().set_shader_param("line_thickness", 0)
	mouse_exited()

func _on_InteractArea_input_event(_viewport, event, _shape_idx):
	if CAN_HOVER:
		try_to_grab_focus()
		if CAN_INTERACT:
			if Input.is_action_just_pressed("inventory_alt") and has_focus and global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) <= INTERACT_DISTANCE:
				object_interacted_with()
			if event is InputEventMouseMotion:
				if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > INTERACT_DISTANCE:
					sprite.get_material().set_shader_param("outline_color", INVALID_OUTLINE_COLOR)
				else:
					sprite.get_material().set_shader_param("outline_color", VALID_OUTLINE_COLOR)

func try_to_grab_focus():
	if Global.num_interacted_with < 1:
		has_focus = true
		Global.num_interacted_with = 1
		
		mouse_entered()
		
		if CAN_INTERACT:
			sprite.get_material().set_shader_param("line_thickness", 1)
			if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > INTERACT_DISTANCE:
				sprite.get_material().set_shader_param("outline_color", INVALID_OUTLINE_COLOR)
			else:
				sprite.get_material().set_shader_param("outline_color", VALID_OUTLINE_COLOR)

func update_debug_info(show_debug: bool):
	if show_debug and is_pathing:
		get_node("Path").visible = true
		get_node("PathTarget").visible = true
		
		var points: Array = [Vector2.ZERO]
		for point in current_path:
			points.append(point - global_position)
		get_node("Path").points = points
		
		get_node("PathTarget").rect_position = points[points.size() - 1] - (get_node("PathTarget").rect_size / 2)
		
		if is_valid_path(path_target, false):
			get_node("PathTarget2").visible = false
		else:
			get_node("PathTarget2").visible = true
			get_node("PathTarget2").rect_position = (path_target - global_position) - (get_node("PathTarget2").rect_size / 2)
	else:
		get_node("Path").visible = false
		get_node("PathTarget").visible = false
		get_node("PathTarget2").visible = false

func set_direction(direction: Vector2):
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	animation_tree.set("parameters/Run/blend_position", direction)

func get_damage_info() -> Dictionary:
	var damage_info: Dictionary = {
		"damage" : DAMAGE,
		"reference" : self,
		"knockback" : dir * KNOCKBACK_STRENGTH,
		"type" : "normal"
	}
	return damage_info

# determine what the character should do each physics process
# warning-ignore:unused_argument
func state_logic(delta):
	pass

# executed when the current path has been follow completely
func finished_path():
	pass

# executed when the health of the character is zero
func dead():
	if has_focus:
		has_focus = false
		Global.num_interacted_with = 0
	set_physics_process(false)
	var death_animation = disappear_effect.instance()
	add_child(death_animation)

# executed on _ready() for classes that need additional setup
func extra_init():
	pass

# executed if CAN_HOVER is true and the character is moused over
func mouse_entered():
	pass

# executed whenever the mouse leaves the character
func mouse_exited():
	pass

# executed if CAN_INTERACT is true and the player right clicks the character
func object_interacted_with():
	pass

# display the damage taken overhead
# warning-ignore:unused_argument
func floating_damage_numbers(damage):
	pass

# warning-ignore:unused_argument
func damage_taken(damage_info: Dictionary):
	pass

func _on_InvincibilityTimer_timeout():
	invincible = false

func _on_VisibilityTimer_timeout():
	health_bar.hide()

func _on_FleeTimer_timeout():
	fleeing = false

# warning-ignore:unused_argument
func _on_ViewDistance_body_entered(body):
	pass
