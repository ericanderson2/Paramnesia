extends Control

func _ready():
# warning-ignore:return_value_discarded
	PlayerData.connect("coins_changed", self, "update_coins")
# warning-ignore:return_value_discarded
	PlayerData.connect("day_changed", self, "update_days")
	update_coins()
	update_days()

func _process(_delta):
	var time: String = "0:00"
	if PlayerData.time_of_day >= 12 and PlayerData.time_of_day < 13:
		time = str(int(PlayerData.time_of_day)) + ":" + str(int((PlayerData.time_of_day - int(PlayerData.time_of_day)) * 60)) + " p.m."
	elif PlayerData.time_of_day >= 13:
		time = str(int(PlayerData.time_of_day - 12)) + ":" + str(int((PlayerData.time_of_day - int(PlayerData.time_of_day)) * 60)) + " p.m."
	elif PlayerData.time_of_day < 1:
		time = "12" + ":" + str(int((PlayerData.time_of_day - int(PlayerData.time_of_day)) * 60)) + " a.m."
	else:
		time = str(int(PlayerData.time_of_day)) + ":" + str(int((PlayerData.time_of_day - int(PlayerData.time_of_day)) * 60)) + " a.m."
	
	get_node("DayIndicator").frame = int(PlayerData.time_of_day)
	get_node("Time").text = time

func update_coins():
	get_node("CoinsAmount").text = str(PlayerData.coins)

func update_days():
	get_node("Day").text = PlayerData.season + " " + str(PlayerData.day)
