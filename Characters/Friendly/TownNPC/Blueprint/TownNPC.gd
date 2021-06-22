extends FriendlyCharacter

class_name TownNPC

const SKIN_COLORS: Array = [Color("f0b577"), Color("c49067"), Color("6f491d"), Color("6a3308"), Color("472104")]
const PUPIL_COLORS: Array = [Color("143eae"), Color("004627"), Color("64300a"), Color("361902"), Color("000000")]
const HAIR_COLORS: Array = [Color("e1d912"), Color("6a4025"), Color("261604"), Color("8d3d21"), Color("7d7d7d")]

enum {
	WALK,
	IDLE
}

onready var body_sprite = get_node("Sprite")
onready var outfit_sprite = get_node("OutfitSprite")
onready var pupils_sprite = get_node("PupilsSprite")
onready var eyes_sprite = get_node("EyesSprite")
onready var brow_sprite = get_node("BrowSprite")
onready var hair_sprite = get_node("HairSprite")
onready var outline_sprite = get_node("OutlineSprite")

export var outfit: int = 0
export var hair: int = 0
export var skin_color: int = 0
export var hair_color: int = 0
export var eye_color: int = 0

var state = IDLE
var arrived: bool = false
var schedule: Schedule

func _ready():
	set_sprites()
	
	outline_sprite.set_material(body_sprite.get_material())

func state_logic(delta):
	if global_position.distance_to(schedule.get_location(PlayerData.time_of_day)) > 16:
		is_pathing = start_path(schedule.get_location(PlayerData.time_of_day))
		arrived = false
	else:
		if not arrived:
			arrived_at_location(schedule.get_location(PlayerData.time_of_day))
		arrived = true
	if is_pathing:
		state = WALK
	else:
		state = IDLE

	match state:
		WALK:
			walk(delta)
		IDLE:
			idle(delta)

func walk(delta):
	if is_pathing:
		follow_current_path(delta)
	if running:
		animation_state.travel("Run")
	else:
		animation_state.travel("Walk")

func idle(delta):
	animation_state.travel("Idle")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	set_direction(Vector2(0, 1))

# warning-ignore:unused_argument
func arrived_at_location(location: Vector2):
	pass

func set_sprites():
	outfit_sprite.texture = load("res://Player/Parts/outfits/outfit_" + str(outfit) + ".png")
	hair_sprite.texture = load("res://Player/Parts/hair/hair_" + str(hair) + ".png")
	outline_sprite.texture = load("res://Player/Parts/hair/mask_" + str(hair) + ".png")
	
	body_sprite.modulate = SKIN_COLORS[skin_color]
	pupils_sprite.modulate = PUPIL_COLORS[eye_color]
	brow_sprite.modulate = HAIR_COLORS[hair_color]
	hair_sprite.modulate = HAIR_COLORS[hair_color]

func _on_Sprite_frame_changed():
	if body_sprite == null:
		return
	outfit_sprite.frame = body_sprite.frame
	pupils_sprite.frame = body_sprite.frame
	eyes_sprite.frame = body_sprite.frame
	brow_sprite.frame = body_sprite.frame
	hair_sprite.frame = body_sprite.frame
	outline_sprite.frame = body_sprite.frame
