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
		var d = dialog.instance()
		d.text = MissionController.MISSIONS[mission]["start_text"]
		get_tree().get_current_scene().get_node("GUI").add_child(d)
		d.rect_position = get_global_transform_with_canvas().origin
		d.rect_position -= Vector2(102, 30)
		
