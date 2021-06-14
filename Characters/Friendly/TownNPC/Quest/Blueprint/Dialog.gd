extends Control

class_name Dialog

var mission: int = 0
var max_lines: int = 0

signal mission_accepted(mission)

func _ready():
	$Label.text = MissionController.MISSIONS[mission]["start_text"]
	$Mission/Description.text = MissionController.MISSIONS[mission]["description"]
	if MissionController.MISSIONS[mission]["required"]:
		$Mission/Decline.text = "Later"
	
	get_tree().get_current_scene().get_node("GUI").hide_visible()
	get_tree().get_current_scene().get_node("GlobalYSort/Player").lock_movement = true

func _on_Label_resized():
	$Panel.rect_size.y = $Label.rect_size.y + 6
	rect_position.y -= $Panel.rect_size.y
	$Next.rect_position.y = $Panel.rect_position.y + $Panel.rect_size.y
	
	max_lines = $Label.get_line_count()

func _on_Next_pressed():
	if $Label.lines_skipped < max_lines - 4:
		$Label.lines_skipped += 4
	else:
		$Next.visible = false
		$Mission.visible = true

func _on_Accept_pressed():
	emit_signal("mission_accepted", mission)
	get_tree().get_current_scene().get_node("GUI").close_open_window()

func _on_Decline_pressed():
	get_tree().get_current_scene().get_node("GUI").close_open_window()
