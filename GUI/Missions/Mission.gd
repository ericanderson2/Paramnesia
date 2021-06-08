extends Control

onready var background = get_node("Background")
onready var description = get_node("VBoxContainer/Description")

var mission: int = 1
var expanded_size: Vector2
var default_size: Vector2 = Vector2(400, 43)

func _ready():
	get_node("VBoxContainer/HBoxContainer/Title").text = MissionController.MISSIONS[mission]["title"]
	description.text = MissionController.MISSIONS[mission]["description"]

func _process(_delta):
	expanded_size = $VBoxContainer.rect_size + Vector2(6, 6)
	description.visible = false
	set_process(false)

func _on_ExpandButton_toggled(button_pressed):
	if button_pressed:
		get_node("ExpandButton").text = "-"
		description.visible = true
		background.rect_size = expanded_size
		rect_min_size = expanded_size
	else:
		get_node("ExpandButton").text = "+"
		description.visible = false
		background.rect_size = default_size
		rect_min_size = default_size
