extends KinematicBody2D

onready var sprite = get_node("Sprite")
onready var player_body = get_node("YSort/PlayerBody")
onready var player_outfit = get_node("YSort/PlayerOutfit")
onready var player_eyes = get_node("YSort/PlayerEyes")
onready var player_pupils = get_node("YSort/PlayerPupils")
onready var player_brows = get_node("YSort/PlayerBrows")
onready var player_hair = get_node("YSort/PlayerHair")

const MAX_SPEED: float = 100.0
const ACCELERATION: float = 100.0
const FRICTION: float = 20.0
const floating_numbers = preload("res://Effects/DamageNumbers/EnemyNumbers.tscn")

var interact_distance: int = 50
var has_focus: bool = false
export var can_interact: bool = true

var riding: bool = false
var velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
var invincible: bool = false
var health: int = 100 setget set_health

signal boat_entered
signal destroyed

func _ready():
	sprite.set_material(sprite.get_material().duplicate())
	
	player_hair.texture = load("res://Player/Parts/hair/hair_" + str(PlayerData.hair) + ".png")
	player_outfit.texture = load("res://Player/Parts/outfits/outfit_" + str(PlayerData.outfit) + ".png")
	
	player_body.modulate = PlayerData.skin_color
	player_pupils.modulate = PlayerData.eye_color
	player_brows.modulate = PlayerData.brow_color
	player_hair.modulate = PlayerData.hair_color

func _physics_process(delta):
	if riding:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if input_vector != Vector2.ZERO:
			dir = input_vector.normalized()
			get_node("AnimationTree").set("parameters/blend_position", input_vector)
			velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	
	get_node("Particles2D").emitting = not (velocity == Vector2.ZERO)

func _on_InteractArea_mouse_entered():
	if can_interact:
		try_to_grab_focus()

func _on_InteractArea_mouse_exited():
	if has_focus:
		has_focus = false
		Global.num_interacted_with = 0
	sprite.get_material().set_shader_param("line_thickness", 0)

func _on_InteractArea_input_event(_viewport, event, _shape_idx):
	if can_interact:
		try_to_grab_focus()
		if Input.is_action_just_pressed("inventory_alt") and has_focus and global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) <= interact_distance:
			object_interacted_with()
	
	if event is InputEventMouseMotion:
		if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > interact_distance:
			sprite.get_material().set_shader_param("outline_color", Color("#0081ff"))
		else:
			sprite.get_material().set_shader_param("outline_color", Color("#ffffff"))

func try_to_grab_focus():
	if Global.num_interacted_with < 1:
		has_focus = true
		Global.num_interacted_with = 1
		sprite.get_material().set_shader_param("line_thickness", 1)
		
		if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > interact_distance:
			sprite.get_material().set_shader_param("outline_color", Color("#0081ff"))
		else:
			sprite.get_material().set_shader_param("outline_color", Color("#ffffff"))

func set_player_visible(vis: bool):
	player_body.visible = vis
	player_outfit.visible = vis
	player_eyes.visible = vis
	player_pupils.visible = vis
	player_brows.visible = vis
	player_hair.visible = vis

func object_interacted_with():
	riding = not riding
	_on_PlayerBody_frame_changed()
	set_player_visible(riding)
	if riding:
		get_tree().get_current_scene().get_node("GlobalYSort/Player").start_riding(self)
		emit_signal("boat_entered")
	else:
		get_tree().get_current_scene().get_node("GlobalYSort/Player").stop_riding()

func _on_PlayerBody_frame_changed():
	player_outfit.frame = player_body.frame
	player_eyes.frame = player_body.frame
	player_pupils.frame = player_body.frame
	player_brows.frame = player_body.frame
	player_hair.frame = player_body.frame
	
	player_outfit.position = player_body.position
	player_eyes.position = player_body.position
	player_pupils.position = player_body.position
	player_brows.position = player_body.position
	player_hair.position = player_body.position

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
	
	set_health(health - damage)
	
	var numbers = floating_numbers.instance()
	numbers.text = str(damage)
	add_child(numbers)
	
	get_node("HitEffect").emitting = true
	
	if damage >= 1:
		invincible = true
		get_node("Invincibility").start()

func set_health(passed_health: int):
	health = passed_health
	get_node("HealthBar").visible = true
	$Tween.interpolate_property(get_node("HealthBar"), "value", get_node("HealthBar").value, health, 0.3, Tween.TRANS_LINEAR)
	$Tween.start()
	
	if health <= 0:
		emit_signal("destroyed")

func _on_Invincibility_timeout():
	invincible = false
