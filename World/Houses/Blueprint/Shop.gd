extends House

class_name Shop

export var start_time: int = 7

var inventory: Array = []

func extra_init():
# warning-ignore:return_value_discarded
	PlayerData.connect("time_advanced", self, "time_advanced")
	roll_loot_table()

func time_advanced(time: int):
	if time == start_time:
		spawn_shopkeeper()

func spawn_shopkeeper():
	pass

func roll_loot_table():
	pass
