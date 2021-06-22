extends Control

var text: String = ""
var option_1: String = ""
var option_2: String = ""

signal option_selected(option)

func _ready():
	$Label.text = text
	$Option1.text = option_1
	$Option2.text = option_2

func _on_Option1_pressed():
	emit_signal("option_selected", 1)
	get_tree().get_current_scene().get_node("GUI").close_open_window()

func _on_Option2_pressed():
	emit_signal("option_selected", 2)
	get_tree().get_current_scene().get_node("GUI").close_open_window()
