extends House

const horse = preload("res://Characters/Friendly/TamedCreature/Horse/Horse.tscn")

var horses: Array = []
var initialized: bool = false

func _process(_delta):
	if horses.size() == 0:
		for hitch in get_tree().get_nodes_in_group("ShopHorseHitch"):
			var h = horse.instance()
			h.global_position = hitch.get_horse_location()[0]
			h.dir = hitch.get_horse_location()[1]
			h.PLAYER_OWNED = false
			h.CAN_HOVER = false
			get_parent().add_child(h)
			horses.append(h)
			hitch.set_hitch(true)
	if PlayerData.time_of_day > 1.0 and not initialized:
		initialized = true
		for s in get_tree().get_nodes_in_group("HorseShopSign"):
			s.text = "Lot " + str(s.id) + " - "
