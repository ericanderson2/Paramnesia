extends TownNPC

class_name QuestNPC

const dialog = preload("res://Characters/Friendly/TownNPC/Quest/Blueprint/Dialog.tscn")

export var missions: Array

func extra_init():
	schedule = Schedule.new()
	schedule.add_place(0.0, global_position)

func object_interacted_with():
	var mission: int = -1
	for m in missions:
		if MissionController.can_start(m):
			mission = m
			break
	if mission != -1:
		tween.interpolate_property(get_tree().get_current_scene().get_node("GlobalYSort/Player/RemoteTransform2D"), "global_position", get_tree().get_current_scene().get_node("GlobalYSort/Player/RemoteTransform2D").global_position, global_position, 0.3, Tween.TRANS_LINEAR)
		tween.start()
		
		var d = dialog.instance()
		d.mission = mission
		d.connect("mission_accepted", self, "start_mission")
		get_tree().get_current_scene().get_node("GUI").set_current_window(d, false)

# warning-ignore:unused_argument
func start_mission(mission: int):
	pass
