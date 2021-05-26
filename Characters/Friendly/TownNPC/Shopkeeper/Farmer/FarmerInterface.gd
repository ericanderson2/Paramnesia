extends Control

var inventory: Array

func _ready():
	for i in range(0, inventory.size()):
		if i < 3:
			get_node("HBoxContainer/VBoxContainer/Lot" + str(i + 1) + "/Label").text = "Lot " + str(i + 1)
			get_node("HBoxContainer/VBoxContainer/Lot" + str(i + 1) + "/Button").text = str(inventory[i][2])
		else:
			get_node("HBoxContainer/VBoxContainer2/Lot" + str(i + 1) + "/Label").text = "Lot " + str(i + 1)
			get_node("HBoxContainer/VBoxContainer2/Lot" + str(i + 1) + "/Button").text = str(inventory[i][2])

