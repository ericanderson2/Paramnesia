extends TownNPC

class_name Shopkeeper

var inventory: Array

func extra_init():
	set_schedule()
	roll_loot_table()

func object_interacted_with():
	pass

func roll_loot_table():
	pass
