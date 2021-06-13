extends Control

onready var construction = get_node("HBoxContainer/VBoxContainer/ConstructionCounter")
onready var farming = get_node("HBoxContainer/VBoxContainer/FarmingCounter")
onready var trading = get_node("HBoxContainer/VBoxContainer2/TradingCounter")
onready var foraging = get_node("HBoxContainer/VBoxContainer2/ForagingCounter")

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
			max_points = 2
		NORMAL:
			max_points = 1
		HARD:
			max_points = 1
	
	construction.max_amount = 1
	farming.max_amount = 1
	trading.max_amount = 1
	foraging.max_amount = 1
	
	available_points = max_points
	get_node("Points").text = "Specialist Points Left: " + str(available_points) + "/" + str(max_points)

func set_available_points(new_amount):
	if available_points == 0 and new_amount > 0:
		for node in get_tree().get_nodes_in_group("SupplyCounter"):
			node.set_plus_enabled()
	available_points = new_amount
	get_node("Points").text = "Specialist Points Left: " + str(available_points) + "/" + str(max_points)
	if available_points == 0:
		for node in get_tree().get_nodes_in_group("SupplyCounter"):
			node.set_plus_disabled()

func save_points():
	Global.starting_items["construction"] = construction.current_amount
	Global.starting_items["farming"] = farming.current_amount
	Global.starting_items["trading"] = trading.current_amount
	Global.starting_items["foraging"] = foraging.current_amount
