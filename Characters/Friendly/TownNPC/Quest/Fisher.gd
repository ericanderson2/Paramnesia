extends QuestNPC

func start_mission(mission: int):
	MissionController.start_mission(mission)
	match mission:
		1:
			schedule = Schedule.new()
			schedule.add_place(0.0, "Lake")
