extends Shopkeeper

func set_schedule():
	schedule = Schedule.new()
	schedule.add_place(3.0, "HorseShop")

func roll_loot_table():
	inventory = Global.horse_seller_loot_table.roll_table()
