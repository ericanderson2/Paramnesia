extends QuestNPC

func start_mission(mission: int):
	MissionController.start_mission(mission)
	update_indicator()
	match mission:
		1:
			schedule = Schedule.new()
			schedule.add_place(0.0, "Lake")

func arrived_at_location(location: Vector2):
	if location == Global.buildings["Lake"] and get_tree().get_nodes_in_group("Mission1").size() == 0:
		var event = load("res://Control/Events/Mission1/Mission1.tscn").instance()
		get_tree().get_current_scene().get_node("GlobalYSort").add_child(event)
		event.global_position = Vector2(-1056, -464)
		special_interaction = true
		get_node("QuestIndicator").visible = true

func special_interactions():
	if 1 in MissionController.active_missions:
		tween.interpolate_property(get_tree().get_current_scene().get_node("GlobalYSort/Player/RemoteTransform2D"), "global_position", get_tree().get_current_scene().get_node("GlobalYSort/Player/RemoteTransform2D").global_position, global_position, 0.3, Tween.TRANS_LINEAR)
		tween.start()
		
		var d = action_dialog.instance()
		d.text = "You get the rudder. I'll throw the harpoons. Ready to get this shark?"
		d.option_1 = "No"
		d.option_2 = "Yes"
		d.connect("option_selected", self, "start_mission_1")
		get_tree().get_current_scene().get_node("GUI").set_current_window(d, false)

func start_mission_1(option: int):
	if option == 1:
		return
	else:
		special_interaction = false
		update_indicator()
		for m in get_tree().get_nodes_in_group("Mission1"):
			m.start(self)
