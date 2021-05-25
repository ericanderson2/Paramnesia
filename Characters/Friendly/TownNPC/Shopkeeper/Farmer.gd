extends Shopkeeper

func set_schedule():
	schedule = Schedule.new()
	schedule.add_place(3.0, "Building1")
	schedule.add_place(7.0, "Building2")
	schedule.add_place(9.0, Vector2(0, 0))
	schedule.add_place(11.0, Vector2(-250, -250))

func roll_loot_table():
	inventory = Global.horse_seller_loot_table.roll_table()
	print(inventory)
