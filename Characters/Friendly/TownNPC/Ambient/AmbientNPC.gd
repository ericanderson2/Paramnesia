extends TownNPC

class_name AmbientNPC

var skin_colors: Array = [Color("f0b577"), Color("c49067"), Color("6f491d"), Color("6a3308"), Color("472104")]
var pupil_colors: Array = [Color("143eae"), Color("004627"), Color("64300a"), Color("361902"), Color("000000")]
var hair_colors: Array = [Color("e1d912"), Color("6a4025"), Color("261604"), Color("8d3d21"), Color("7d7d7d")]

func extra_init():
	Global.ambient_mobs += 1
	
	get_node("Sprite").modulate = skin_colors[randi() % 5]
	get_node("Pupils").modulate = pupil_colors[randi() % 5]
	get_node("Brows").modulate = hair_colors[randi() % 5]
	get_node("Hair").modulate = hair_colors[randi() % 5]
	
	schedule = Schedule.new()
	schedule.add_place(0.0, schedule.random_building())

func state_logic(delta):
	if global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > 400:
		Global.ambient_mobs -= 1
		queue_free()
	if global_position.distance_to(schedule.get_location(PlayerData.time_of_day)) > 3:
		is_pathing = start_path(schedule.get_location(PlayerData.time_of_day))
	else:
		Global.ambient_mobs -= 1
		queue_free()
	if is_pathing:
		state = WALK
	else:
		state = IDLE

	match state:
		WALK:
			walk(delta)
		IDLE:
			idle(delta)

func _on_Sprite_frame_changed():
	get_node("Outfit").frame = get_node("Sprite").frame
	get_node("Eyes").frame = get_node("Sprite").frame
	get_node("Pupils").frame = get_node("Sprite").frame
	get_node("Brows").frame = get_node("Sprite").frame
	get_node("Hair").frame = get_node("Sprite").frame
