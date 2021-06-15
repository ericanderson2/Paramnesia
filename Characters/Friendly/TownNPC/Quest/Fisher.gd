extends QuestNPC

func start_mission(mission: int):
	MissionController.start_mission(mission)
	update_indicator()
	match mission:
		1:
			schedule = Schedule.new()
			schedule.add_place(0.0, "Lake")
		2:
			var event = load("res://Control/Events/Mission1.tscn").instance()
			get_tree().get_current_scene().get_node("GlobalYSort").add_child(event)
			event.global_position = Vector2(-1056, -464)
