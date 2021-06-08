extends Control

const MissionBox = preload("res://GUI/Missions/Mission.tscn")

onready var vbox = get_node("ScrollContainer/VBoxContainer")

func _ready():
	for mission in MissionController.active_missions:
		var mission_box = MissionBox.instance()
		mission_box.mission = mission
		vbox.add_child(mission_box)
		get_node("NoMissions").visible = false
