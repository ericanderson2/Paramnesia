extends Control

onready var cattle = get_node("HBoxContainer/VBoxContainer/CattleCounter")
onready var pig = get_node("HBoxContainer/VBoxContainer/PigCounter")
onready var goat = get_node("HBoxContainer/VBoxContainer/GoatCounter")
onready var sheep = get_node("HBoxContainer/VBoxContainer2/SheepCounter")
onready var chicken = get_node("HBoxContainer/VBoxContainer2/ChickenCounter")
onready var rabbit = get_node("HBoxContainer/VBoxContainer2/RabbitCounter")

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
			max_points = 10
			
			cattle.max_amount = 4
			pig.max_amount = 6
			goat.max_amount = 6
			sheep.max_amount = 6
			chicken.max_amount = 10
			rabbit.max_amount = 10
		NORMAL:
			max_points = 6
			
			cattle.max_amount = 2
			pig.max_amount = 4
			goat.max_amount = 4
			sheep.max_amount = 4
			chicken.max_amount = 6
			rabbit.max_amount = 6
		HARD:
			max_points = 4
			
			cattle.max_amount = 1
			pig.max_amount = 2
			goat.max_amount = 2
			sheep.max_amount = 2
			chicken.max_amount = 4
			rabbit.max_amount = 4
	
	available_points = max_points
	get_node("Points").text = "Livestock Points Left: " + str(available_points) + "/" + str(max_points)

func set_available_points(new_amount):
	if available_points == 0 and new_amount > 0:
		for node in get_tree().get_nodes_in_group("LivestockCounter"):
			node.set_plus_enabled()
	available_points = new_amount
	get_node("Points").text = "Livestock Points Left: " + str(available_points) + "/" + str(max_points)
	if available_points == 0:
		for node in get_tree().get_nodes_in_group("LivestockCounter"):
			node.set_plus_disabled()

func save_points():
	Global.starting_items["cow"] = cattle.current_amount
	Global.starting_items["pig"] = pig.current_amount
	Global.starting_items["goat"] = goat.current_amount
	Global.starting_items["sheep"] = sheep.current_amount
	Global.starting_items["chicken"] = chicken.current_amount
	Global.starting_items["rabbit"] = rabbit.current_amount
