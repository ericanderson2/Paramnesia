extends Control

onready var wood = get_node("HBoxContainer/VBoxContainer/Wood")
onready var stone = get_node("HBoxContainer/VBoxContainer/Stone")
onready var fiber = get_node("HBoxContainer/VBoxContainer/Fiber")
onready var ingots = get_node("HBoxContainer/VBoxContainer2/Ingots")
onready var obsidian = get_node("HBoxContainer/VBoxContainer2/Obsidian")
onready var coins = get_node("HBoxContainer/VBoxContainer2/Coins")

var max_points: int
var available_points: int setget set_available_points

enum {
	EASY,
	NORMAL,
	HARD
}

func _ready():
	match Global.difficulty:
		EASY:
			max_points = 20
			
			wood.max_amount = 20
			stone.max_amount = 20
			fiber.max_amount = 20
			ingots.max_amount = 10
			obsidian.max_amount = 20
			coins.max_amount = 10
		NORMAL:
			max_points = 10
			
			wood.max_amount = 6
			stone.max_amount = 6
			fiber.max_amount = 10
			ingots.max_amount = 5
			obsidian.max_amount = 6
			coins.max_amount = 4
		HARD:
			max_points = 8
			
			wood.max_amount = 4
			stone.max_amount = 4
			fiber.max_amount = 4
			ingots.max_amount = 3
			obsidian.max_amount = 4
			coins.max_amount = 3
	
	available_points = max_points
	get_node("Points").text = "Resource Points Left: " + str(available_points) + "/" + str(max_points)

func set_available_points(new_amount):
	if available_points == 0 and new_amount > 0:
		for node in get_tree().get_nodes_in_group("ResourceCounter"):
			node.set_plus_enabled()
	available_points = new_amount
	get_node("Points").text = "Resource Points Left: " + str(available_points) + "/" + str(max_points)
	if available_points == 0:
		for node in get_tree().get_nodes_in_group("ResourceCounter"):
			node.set_plus_disabled()

func save_points():
	Global.starting_items["wood"] = wood.current_amount
	Global.starting_items["stone"] = stone.current_amount
	Global.starting_items["fiber"] = fiber.current_amount
	Global.starting_items["metal"] = ingots.current_amount
	Global.starting_items["obsidian"] = obsidian.current_amount
	Global.starting_items["coin"] = coins.current_amount
