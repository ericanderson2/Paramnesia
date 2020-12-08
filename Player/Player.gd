extends KinematicBody2D

export var FRICTION = 400
export var ACCELERATION = 500
export var MAX_SPEED = 100
export var DRAIN = 10
export var starting_direction = Vector2(1, 0)

enum {
	MOVE,
	ATTACK
}

var weapon = 1
var state = MOVE
var velocity = Vector2.ZERO
var can_move = true
var structure = null
var last_held
var base_projectile_damge = 25
var base_melee_damage = 40

const unplaced_structure = preload("res://Structures/Blueprint/Unplaced/UnplacedObject.tscn")
const arrow = preload("res://Player/Arrow.tscn")
const floating_numbers = preload("res://Effects/DamageNumbers/EnemyNumbers.tscn")

onready var animationPlayer = get_node("AnimationPlayer")
onready var animationTree = get_node("AnimationTree")
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = get_node("SwordHitbox Pivot/SwordHitbox")
onready var hurtbox = get_node("Hurtbox")
onready var sprite = get_node("Sprite")

enum {
	LEFT,
	RIGHT,
	UP,
	DOWN
}

func _ready():
	animationTree.active = true
	sprite.set_material(sprite.get_material().duplicate())
	set_direction(starting_direction)

func update_from_save(data):
	global_position.x = data["pos_x"]
	global_position.y = data["pos_y"]
	var direction = Vector2(data["dir_x"], data["dir_y"])
	set_direction(direction)

func _physics_process(delta):
	if can_move:
		match state:
			MOVE:
				move_state(delta)
			ATTACK:
				attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	if can_move:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		swordHitbox.knockback_vector = input_vector
		set_direction(input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	if structure != null:
		if PlayerData.holding != last_held or PlayerData.get_item_held() != structure.id:
			structure.queue_free()
			structure = null
		elif can_move:
			structure.global_position = get_global_mouse_position()
	
	last_held = PlayerData.holding
	
	if Input.is_action_just_pressed("attack") and can_move:
		if structure == null:
			if ItemDictionary.get_item(PlayerData.get_item_held())["type"] == "structure":
				create_structure(PlayerData.get_item_held())
			else:
				if PlayerData.get_item_held() == "bow":
					if PlayerData.get_num_held("arrow") > 0:
						create_arrow()
				else:
					state = ATTACK
		elif structure.can_place():
			structure.place()
			PlayerData.remove_from_slot(PlayerData.holding, 1)
			structure = null

func attack_state(_delta):
	velocity = Vector2.ZERO
	if PlayerData.get_item_held() == "stone_axe":
		animationState.travel("Axe")
	elif PlayerData.get_item_held() == null or ItemDictionary.get_item(PlayerData.get_item_held())["type"] == "resource" or PlayerData.get_item_held() == "hands":
		animationState.travel("Pick")
	else:
		state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	sprite.get_material().set_shader_param("highlight", true)
	var damage = 0
	if area.get_parent().has_method("get_damage"):
		damage = area.get_parent().get_damage()
	if area.get_parent().has_method("resolve_hit"):
		area.get_parent().resolve_hit()
	
	get_node("HitEffect").start()
	
	var numbers = floating_numbers.instance()
	numbers.text = str(damage)
	add_child(numbers)
	
	hurtbox.start_invicibility(1)

func _on_GUI_inventory_changed(value):
	can_move = not value

func get_direction_facing():
	var blend_position = animationTree.get("parameters/Idle/blend_position")
	if blend_position.x == -1:
		return LEFT
	if blend_position.x == 1:
		return RIGHT
	if blend_position.y == -1:
		return UP
	else:
		return DOWN

func create_structure(structure_id):
	structure = unplaced_structure.instance()
	structure.id = structure_id
	get_parent().call_deferred("add_child", structure)

func set_direction(direction):
	animationTree.set("parameters/Idle/blend_position", direction)
	animationTree.set("parameters/Run/blend_position", direction)
	animationTree.set("parameters/Axe/blend_position", direction)
	animationTree.set("parameters/Pick/blend_position", direction)

func create_arrow():
	PlayerData.remove_one("arrow")
	var arr = arrow.instance()
	arr.global_position = global_position + Vector2(0, -12)
	var dir = global_position.direction_to(get_global_mouse_position())
	arr.direction = dir
	arr.rotate(dir.angle())
	arr.damage = base_projectile_damge
	get_parent().add_child(arr)

func get_damage():
	return base_melee_damage

func apply_offset(offset):
	global_position += offset

func save():
	var save_dict = {
		"filename" : get_filename(),
		"id" : "player",
		"pos_x" : position.x,
		"pos_y" : position.y,
		"health" : PlayerData.health,
		"level" : PlayerData.level,
		"inventory" : PlayerData.inventory,
		"dir_x" : animationTree.get("parameters/Idle/blend_position").x,
		"dir_y" : animationTree.get("parameters/Idle/blend_position").y
		}
	return save_dict

func _on_HitEffect_timeout():
	sprite.get_material().set_shader_param("highlight", false)
