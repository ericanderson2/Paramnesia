extends Node

class_name Schedule

var schedule: Dictionary = {}

func add_place(time: float, place):
	schedule[str(time)] = place

func get_location(current_time: float):
	if schedule.keys().size() < 1:
		return Vector2(-500, 500)
	var closest_time_before = schedule.keys()[0]
	for time in schedule.keys():
		if float(time) <= current_time and current_time - float(time) < current_time - float(closest_time_before):
			closest_time_before = time
	if schedule[closest_time_before] is String:
		return Global.buildings[schedule[closest_time_before]]
	else:
		return schedule[closest_time_before]

func random_building() -> String:
	return Global.buildings.keys()[randi() % Global.buildings.keys().size()]

func debug():
	print(schedule)
