extends StaticBody2D

class_name House

export var interior_path: String
export var door_direction: Vector2 = Vector2(0, 1)
export var id: String = ""
export var can_enter: bool = true
export var modify_tilemap: bool = false
export var steampunk_modifier: int = 2

onready var base = get_node("Base")

var rectangles: Array

func _ready():
# warning-ignore:return_value_discarded
	get_node("Door").connect("door_opened", self, "door_opened")
	
	if id != "":
		Global.buildings[id] = get_node("Door").global_position
	
	if not can_enter:
		get_node("Door").queue_free()
	
	if modify_tilemap:
		get_node("Base").tile_set = load("res://World/Houses/Blueprint/Tilesets/Steampunk/steampunk_" + str(steampunk_modifier) + ".tres")
		get_node("Roof").tile_set = load("res://World/Houses/Blueprint/Tilesets/Steampunk/steampunk_" + str(steampunk_modifier) + ".tres")
	
	var tiles = base.get_used_cells()
	for tile in tiles:
		rectangles.append(base.map_to_world(tile) + global_position)
	
	extra_init()

func get_pathfinding_rectangles() -> Array:
	return rectangles

func door_opened():
	get_tree().get_current_scene().get_node("GlobalYSort/Player").set_direction(door_direction)
	get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position = get_node("Door").global_position + Vector2(0, 10)
	Global.enter_interior(interior_path)

func extra_init():
	pass
