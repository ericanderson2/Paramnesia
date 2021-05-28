extends StaticBody2D

class_name StaticStructure

onready var sprite = get_node("Sprite")

export var collision: bool = true
export var background: bool = false
export var interact_distance: int = 50
export var can_interact: bool = true
export var can_hover: bool = true

var has_focus: bool = false

func _ready():
	sprite.set_material(sprite.get_material().duplicate())
	sprite.get_material().set_shader_param("line_thickness", 0)
	get_node("CollisionShape2D").disabled = not collision
	if background:
		z_index = -5
	extra_init()

func _on_InteractArea_mouse_entered():
	if can_interact:
		try_to_grab_focus()

func _on_InteractArea_mouse_exited():
	if has_focus:
		has_focus = false
		Global.num_interacted_with = 0
	exit_mouse()
	sprite.get_material().set_shader_param("line_thickness", 0)

func _on_InteractArea_input_event(_viewport, event, _shape_idx):
	try_to_grab_focus()
	if can_interact and Input.is_action_just_pressed("inventory_alt") and has_focus and global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) <= interact_distance:
		object_interacted_with()
	if event is InputEventMouseMotion and can_interact:
		if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > interact_distance:
			sprite.get_material().set_shader_param("outline_color", Color("#0081ff"))
		else:
			sprite.get_material().set_shader_param("outline_color", Color("#ffffff"))

func try_to_grab_focus():
	if Global.num_interacted_with < 1:
		has_focus = true
		Global.num_interacted_with = 1
			
		if can_interact:
			sprite.get_material().set_shader_param("line_thickness", 1)
				
			if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > interact_distance:
				sprite.get_material().set_shader_param("outline_color", Color("#0081ff"))
			else:
				sprite.get_material().set_shader_param("outline_color", Color("#ffffff"))

		if can_hover:
			enter_mouse()

func enter_mouse():
	pass

func exit_mouse():
	pass

func object_interacted_with():
	pass

func extra_init():
	pass
