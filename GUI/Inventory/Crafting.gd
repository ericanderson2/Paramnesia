extends Panel

onready var recipes = get_node("ScrollContainer/Recipes")
onready var info = get_node("InfoPanel")

onready var level_button = get_node("InfoPanel/Options/LevelButton")
onready var alphabetical_button = get_node("InfoPanel/Options/AlphabeticalButton")

var selected = null
var locked_in: bool = false

func _ready():
	redraw()

func _input(_event):
	var cursor_pos = get_global_mouse_position()
	if not locked_in:
		if get_node("ClickBounds").get_global_rect().has_point(cursor_pos):
			selected = recipes.get_item_at_location(cursor_pos)
		else:
			selected = null
	if Input.is_action_just_pressed("inventory_main"):
		if get_node("ClickBounds").get_global_rect().has_point(cursor_pos):
			selected = recipes.get_item_at_location(cursor_pos)
			if selected != null:
				locked_in = true
			else:
				locked_in = false
		elif get_node("InfoPanel").get_global_rect().has_point(cursor_pos):
			pass
		else:
			locked_in = false
			selected = null
	redraw()

func redraw():
	recipes.redraw()
	info.redraw()

func _on_LevelButton_toggled(button_pressed):
	if button_pressed:
		alphabetical_button.pressed = false
		recipes.sort_mode = "level"
	else:
		if not alphabetical_button.pressed:
			recipes.sort_mode = "default"

func _on_AlphabeticalButton_toggled(button_pressed):
	if button_pressed:
		level_button.pressed = false
		recipes.sort_mode = "alphabetical"
	else:
		if not level_button.pressed:
			recipes.sort_mode = "default"
