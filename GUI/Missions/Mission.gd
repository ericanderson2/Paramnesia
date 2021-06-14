extends Control

onready var background = get_node("Background")
onready var description = get_node("VBoxContainer/Description")

var mission: int = 1
var expanded_size: Vector2
var default_size: Vector2 = Vector2(400, 28)
var button_pressed: bool = false

func _ready():
	get_node("VBoxContainer/HBoxContainer/Title").text = MissionController.MISSIONS[mission]["title"]
	description.text = MissionController.MISSIONS[mission]["description"]

func _process(_delta):
	expanded_size = $VBoxContainer.rect_size + Vector2(6, 6)
	description.visible = false
	set_process(false)

func _on_Tween_tween_all_completed():
	if rect_min_size == expanded_size:
		description.visible = true

func _on_ExpandButton_pressed():
	if $Tween.is_active():
		return
	button_pressed = not button_pressed
	if button_pressed:
		get_node("ExpandButton").text = "-"
		$Tween.interpolate_property(background, "rect_size", background.rect_size, expanded_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(self, "rect_min_size", rect_min_size, expanded_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		get_node("ExpandButton").text = "+"
		description.visible = false
		$Tween.interpolate_property(background, "rect_size", background.rect_size, default_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_property(self, "rect_min_size", rect_min_size, default_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
