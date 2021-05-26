extends TownNPC

class_name Shopkeeper

export var interface: String

var inventory: Array

func extra_init():
	set_schedule()
	roll_loot_table()

func object_interacted_with():
	var i = load(interface).instance()
	i.inventory = inventory
	get_tree().get_current_scene().set_gui_window(i)

func roll_loot_table():
	pass
