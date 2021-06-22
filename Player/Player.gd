extends KinematicBody2D

export var FRICTION = 400
export var ACCELERATION = 500
export var MAX_SPEED = 100
export var DRAIN = 10
export var starting_direction = Vector2(1, 0)
export var KNOCKBACK_STRENGTH: float = 100.0

enum {
	MOVE,
	ATTACK,
	PLACE
}

var weapon = 1
var state = MOVE
var velocity: Vector2 = Vector2.ZERO
var structure = null
var last_held
var base_projectile_damage: int = 25
var base_melee_damage: int = 40
var lock_movement: bool = false setget set_lock_movement
var knockback: Vector2 = Vector2.ZERO
var pathfinding
var invincible: bool = false
var dir: Vector2 = Vector2.ZERO
var riding: bool = false
var current_mount: Object = null

const unplaced_structure = preload("res://Structures/Blueprint/Unplaced/UnplacedObject.tscn")
const bola = preload("res://Player/Projectiles/Bola.tscn")
const floating_numbers = preload("res://Effects/DamageNumbers/EnemyNumbers.tscn")

onready var animationPlayer = get_node("AnimationPlayer")
onready var animationTree = get_node("AnimationTree")
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = get_node("SwordHitbox Pivot/SwordHitbox")
onready var hurtbox = get_node("Hurtbox")
onready var sprite = get_node("Sprite")
onready var body_sprite = get_node("Body")
onready var outfit_sprite = get_node("Outfit")
onready var eyes_sprite = get_node("Eyes")
onready var pupils_sprite = get_node("Pupils")
onready var brows_sprite = get_node("Brows")
onready var hair_sprite = get_node("Hair")
onready var holding_sprite = get_node("Holding")

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
	set_sprites()
	
	body_sprite.set_material(body_sprite.get_material().duplicate())
	outfit_sprite.set_material(body_sprite.get_material())
	eyes_sprite.set_material(body_sprite.get_material())
	pupils_sprite.set_material(body_sprite.get_material())
	brows_sprite.set_material(body_sprite.get_material())
	hair_sprite.set_material(body_sprite.get_material())
	holding_sprite.set_material(body_sprite.get_material())

func set_sprites():
	get_node("Hair").texture = load("res://Player/Parts/hair/hair_" + str(PlayerData.hair) + ".png")
	get_node("Outfit").texture = load("res://Player/Parts/outfits/outfit_" + str(PlayerData.outfit) + ".png")
	get_node("Body").modulate = PlayerData.skin_color
	get_node("Hair").modulate = PlayerData.hair_color
	get_node("Brows").modulate = PlayerData.brow_color
	get_node("Pupils").modulate = PlayerData.eye_color

func initialize(passed_pathfinding):
	pathfinding = passed_pathfinding

func update_from_save(data):
	global_position.x = data["pos_x"]
	global_position.y = data["pos_y"]
	var direction = Vector2(data["dir_x"], data["dir_y"])
	set_direction(direction)
	
	PlayerData.hair = data["hair"]
	PlayerData.outfit = data["outfit"]
	PlayerData.skin_color = data["skin_color"]
	PlayerData.hair_color = data["hair_color"]
	PlayerData.brow_color = data["brow_color"]
	PlayerData.eye_color = data["eye_color"]
	set_sprites()
	
	PlayerData.level = data["level"]
	PlayerData.inventory = data["inventory"]
	PlayerData.emit_signal("inventory_updated")

func _physics_process(delta):
	if riding:
		global_position = current_mount.global_position
		return
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		PLACE:
			place_state()
	knockback = knockback.move_toward(Vector2.ZERO, delta * 400)
	knockback = move_and_slide(knockback)
	
	if not Global.do_day_cycle:
		get_node("Light2D").visible = false
	else:
		get_node("Light2D").visible = true 

func _unhandled_input(event):
	if riding:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("attack"):
			if PlayerData.get_item_held().id == "bola":
				dir = global_position.direction_to(get_global_mouse_position())
				set_direction(dir)
				state = ATTACK
			elif ItemDictionary.get_item(PlayerData.get_item_held().id)["type"] == "structure":
				if structure == null:
					create_structure(PlayerData.get_item_held())
					state = PLACE
				elif structure.can_place():
					structure.place()
					PlayerData.remove_from_slot(PlayerData.holding, 1)
					structure = null
					state = MOVE
				else:
					structure.queue_free()
					structure = null
					state = MOVE
			else:
				state = ATTACK
	elif Input.is_action_just_pressed("control"):
		PlayerData.holding = 1 - PlayerData.holding

func place_state():
	animationState.travel("Idle")
	if structure != null:
		var x = int(get_global_mouse_position().x) - int(get_global_mouse_position().x) % 16 + 8
		var y = int(get_global_mouse_position().y) - int(get_global_mouse_position().y) % 16 + 8
		structure.global_position = Vector2(x, y)
		if PlayerData.get_item_held() != structure.id:
			structure.queue_free()
			structure = null
			state = MOVE

func move_state(delta):
	var input_vector = Vector2.ZERO
	if not lock_movement:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		dir = input_vector
		set_direction(input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	last_held = PlayerData.holding

func attack_state(_delta):
	velocity = Vector2.ZERO
	if PlayerData.get_item_held().id == "stone_axe":
		animationState.travel("Axe")
	elif PlayerData.get_item_held() == null or ItemDictionary.get_item(PlayerData.get_item_held().id)["type"] == "resource" or PlayerData.get_item_held().id == "hands":
		animationState.travel("Eat")
	elif PlayerData.get_item_held().id == "bola":
		animationState.travel("Throw")
	else:
		state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if area.get_parent().has_method("resolve_hit"):
		area.get_parent().resolve_hit()
	
	if invincible or not area.get_parent().has_method("get_damage_info"):
		return

	var damage_info: Dictionary = area.get_parent().get_damage_info()
	var damage: int = damage_info["damage"]
	var reference: Object = damage_info["reference"]
	knockback = damage_info["knockback"]

	get_node("HitEffect").start()
	body_sprite.get_material().set_shader_param("highlight", true)
	
	var numbers = floating_numbers.instance()
	numbers.text = str(damage)
	add_child(numbers)
	
	get_tree().call_group("Tamed", "ally_attacked", reference)
	invincible = true
	hurtbox.get_node("Timer").start(0.4)

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
	animationTree.set("parameters/Eat/blend_position", direction)
	animationTree.set("parameters/Throw/blend_position", direction)

func throw_item():
	if PlayerData.remove_item("bola"):
		var throwable = bola.instance()
		get_parent().add_child(throwable)
		throwable.global_position = global_position + Vector2(0, -12) + dir * 5
		throwable.direction = global_position.direction_to(get_global_mouse_position())

func apply_offset(offset):
	global_position += offset

func save():
	var save_dict = {
		"filename" : get_filename(),
		"id" : "player",
		"pos_x" : position.x,
		"pos_y" : position.y,
		"level" : PlayerData.level,
		"inventory" : PlayerData.inventory,
		"hair" : PlayerData.hair,
		"outfit" : PlayerData.outfit,
		"skin_color" : PlayerData.skin_color.to_html(false),
		"hair_color" : PlayerData.hair_color.to_html(false),
		"brow_color" : PlayerData.brow_color.to_html(false),
		"eye_color" : PlayerData.eye_color.to_html(false),
		"dir_x" : animationTree.get("parameters/Idle/blend_position").x,
		"dir_y" : animationTree.get("parameters/Idle/blend_position").y
		}
	return save_dict

func _on_HitEffect_timeout():
	body_sprite.get_material().set_shader_param("highlight", false)

func set_lock_movement(new_state):
	lock_movement = new_state
	if lock_movement == true and structure != null:
		structure.queue_free()
		structure = null

func _on_Timer_timeout():
	invincible = false

func start_riding(mount: Object):
	current_mount = mount
	riding = true
	
	body_sprite.visible = false
	outfit_sprite.visible = false
	eyes_sprite.visible = false
	pupils_sprite.visible = false
	brows_sprite.visible = false
	hair_sprite.visible = false
	holding_sprite.visible = false
	
	get_node("CollisionShape2D").disabled = true
	get_node("Hurtbox/CollisionShape2D").disabled = true

func stop_riding():
	riding = false
	
	body_sprite.visible = true
	outfit_sprite.visible = true
	eyes_sprite.visible = true
	pupils_sprite.visible = true
	brows_sprite.visible = true
	hair_sprite.visible = true
	
	get_node("Hurtbox/CollisionShape2D").set_deferred("disabled", false)
	get_node("CollisionShape2D").set_deferred("disabled", false)
	
	global_position = current_mount.global_position + Vector2(0, 15)
