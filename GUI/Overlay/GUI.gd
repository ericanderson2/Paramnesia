extends CanvasLayer

const inventory_open = preload("res://GUI/Inventory/Inventory.tscn")
const missions_open = preload("res://GUI/Missions/Missions.tscn")

onready var debug_overlay = get_node("DebugText")
onready var missions_button = get_node("MissionsButton")

var is_inventory_open: bool = false
var missions = null
var current_window = null setget set_current_window

func _process(_delta):
	var debug_text = str(Engine.get_frames_per_second()) + " fps"
	debug_text += "\nRAM Usage: " + String.humanize_size(OS.get_static_memory_usage())
	var x_coord = str(round(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position.x))
	var y_coord = str(round(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position.y))
	debug_text += "\nX: " + x_coord + " Y: " + y_coord
	debug_overlay.text = debug_text

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("inventory_open"):
		if current_window == null:
			is_inventory_open = true
			set_current_window(inventory_open.instance())
		elif is_inventory_open:
			is_inventory_open = false
			close_open_window()

func hide_visible():
	get_node("ItemsOverlay").visible = false
	get_node("Overlay").visible = false
	get_node("DebugText").visible = false
	get_node("MissionsButton").visible = false
	missions_button.visible = false

func show_visible():
	get_node("ItemsOverlay").visible = true
	get_node("Overlay").visible = true
	get_node("DebugText").visible = true
	get_node("MissionsButton").visible = true
	missions_button.visible = true

func close_open_window():
	if current_window == null:
		return true
	else:
		current_window.queue_free()
		current_window = null
		if is_inventory_open:
			is_inventory_open = false
		show_visible()
		get_parent().get_node("GlobalYSort/Player").lock_movement = false
		get_parent().get_node("GlobalYSort/Player/RemoteTransform2D").global_position = get_parent().get_node("GlobalYSort/Player").global_position
		get_node("WindowBlocker").visible = false
		return false

func _on_MissionsButton_pressed():
	missions_button.texture_normal = load("res://GUI/missions_read.png")
	set_current_window(missions_open.instance())

func new_mission():
	missions_button.texture_normal = load("res://GUI/missions_unread.png")

func set_current_window(window, gray_screen: bool = true):
	close_open_window()
	hide_visible()
	get_parent().get_node("GlobalYSort/Player").lock_movement = true
	if current_window != null:
		current_window.queue_free()
	current_window = window
	add_child(current_window)
	
	if gray_screen:
		get_node("WindowBlocker").modulate.a = 0
		get_node("WindowBlocker").visible = true
		get_node("AnimationPlayer").play("BlockWindow")
