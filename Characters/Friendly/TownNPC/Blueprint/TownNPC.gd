extends FriendlyCharacter

class_name TownNPC

enum {
	WALK,
	IDLE
}

var state = IDLE
var schedule: Schedule

func extra_init():
	set_schedule()

func state_logic(delta):
	if global_position.distance_to(schedule.get_location(PlayerData.time_of_day)) > 16:
		is_pathing = start_path(schedule.get_location(PlayerData.time_of_day))
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

func set_schedule():
	pass
