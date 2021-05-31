extends Node

const notification = preload("res://Control/Missions/Notification.tscn")
const MISSIONS: Dictionary = {
	1 : {
		"prereqs" : [],
		"title" : "Gone Fishing",
		"start_text" : "Crazy storm last night, huh? They're saying a bull shark swam up into the pond during the flooding. Hey... would you want to help me capture that shark?",
		"required" : true
	}
}

var completed_missions = []
var active_missions = []

func check_prereqs(mission: int):
	var prereqs: Array = MISSIONS[mission]["prereqs"]
	for req in prereqs:
		if not req in completed_missions:
			return false
	return true

func can_start(mission: int):
	return (not mission in completed_missions) and (not mission in active_missions) and check_prereqs(mission)

func start_mission(mission: int):
	active_missions.append(mission)
	var n = notification.instance()
	n.text = "Mission Started: " + MISSIONS[mission]["title"]
	var gui = get_tree().get_current_scene().get_node("GUI")
	gui.add_child(n)
	gui.new_mission()

func delete_mission(mission):
	if not MISSIONS[mission]["required"]:
		active_missions.erase(mission)

#func player_inventory_changed():
#	if active_missions.size() < 1:
#		return
#	for m in active_missions:
#		if m["type"] == "item":
#			if PlayerData.has_items(m["item_list"]):
#				mission_done(m)

#func mission_done(m):
#	active_missions.erase(m)
#	completed_missions.append(m["id"])
#	if m["reward"] == "item":
#		PlayerData.add_list_to_inventory(0, m["reward_items"])
#	var n = notification.instance()
#	n.text = "Mission Completed: " + m["title"]
#	var gui = get_tree().get_current_scene().get_node("GUI")
#	gui.add_child(n)
#	gui.new_mission()
