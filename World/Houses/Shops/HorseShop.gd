extends Shop

const seller = preload("res://Characters/Friendly/TownNPC/Shopkeeper/Farmer/Farmer.tscn")
const horse = preload("res://Characters/Friendly/TamedCreature/Horse/Horse.tscn")

func roll_loot_table():
	inventory = Global.horse_seller_loot_table.roll_table()

func spawn_shopkeeper():
	var s = seller.instance()
	s.global_position = global_position + Vector2(0, 10)
	get_tree().get_current_scene().get_node("GlobalYSort/Mobs").add_child(s)
	
	var schedule = Schedule.new()
	schedule.add_place(2.0, Vector2(-360, 111))
	schedule.add_place(8.0, "HorseShop")
	s.schedule = schedule
	
	s.shop = self
	
	setup_horses()

func setup_horses():
	for hitch in get_tree().get_nodes_in_group("ShopHorseHitch"):
		var h = horse.instance()
		h.global_position = hitch.get_horse_location()[0]
		h.dir = hitch.get_horse_location()[1]
		h.PLAYER_OWNED = false
		h.CAN_HOVER = false
		get_parent().add_child(h)
		hitch.set_hitch(true)
	
	for s in get_tree().get_nodes_in_group("HorseShopSign"):
			s.text = "Lot " + str(s.id) + " - " + str(inventory[s.id - 1][2])
