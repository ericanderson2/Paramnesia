extends Control

class_name Dialog

var text: String = ""

func _ready():
	get_node("Label").text = text

func _on_Label_resized():
	get_node("Panel").rect_size.y = get_node("Label").rect_size.y + 6
	rect_position.y -= get_node("Panel").rect_size.y
