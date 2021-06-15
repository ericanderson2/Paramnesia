extends KinematicBody2D

onready var sprite = get_node("Sprite")

const MAX_SPEED: float = 100.0
const ACCELERATION: float = 100.0
const FRICTION: float = 20.0

var interact_distance: int = 50
var has_focus: bool = false
var can_interact: bool = true

var riding: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready():
	get_node("PlayerHair").texture = load("res://Player/Parts/hair/hair_" + str(PlayerData.hair) + ".png")
	get_node("PlayerOutfit").texture = load("res://Player/Parts/outfits/outfit_" + str(PlayerData.outfit) + ".png")
	
	get_node("PlayerBody").modulate = PlayerData.skin_color
	get_node("PlayerPupils").modulate = PlayerData.eye_color
	get_node("PlayerBrows").modulate = PlayerData.brow_color
	get_node("PlayerHair").modulate = PlayerData.hair_color

func _physics_process(delta):
	if riding:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		var dir = input_vector.normalized()
		if input_vector != Vector2.ZERO:
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
	get_node("PlayerBody").visible = vis
	get_node("PlayerOutfit").visible = vis
	get_node("PlayerEyes").visible = vis
	get_node("PlayerPupils").visible = vis
	get_node("PlayerBrows").visible = vis
	get_node("PlayerHair").visible = vis

func object_interacted_with():
	riding = not riding
	_on_PlayerBody_frame_changed()
	set_player_visible(riding)
	if riding:
		get_tree().get_current_scene().get_node("GlobalYSort/Player").start_riding(self)
	else:
		get_tree().get_current_scene().get_node("GlobalYSort/Player").stop_riding()

func _on_PlayerBody_frame_changed():
	get_node("PlayerOutfit").frame = get_node("PlayerBody").frame
	get_node("PlayerEyes").frame = get_node("PlayerBody").frame
	get_node("PlayerPupils").frame = get_node("PlayerBody").frame
	get_node("PlayerBrows").frame = get_node("PlayerBody").frame
	get_node("PlayerHair").frame = get_node("PlayerBody").frame
	
	get_node("PlayerOutfit").position = get_node("PlayerBody").position
	get_node("PlayerEyes").position = get_node("PlayerBody").position
	get_node("PlayerPupils").position = get_node("PlayerBody").position
	get_node("PlayerBrows").position = get_node("PlayerBody").position
	get_node("PlayerHair").position = get_node("PlayerBody").position
