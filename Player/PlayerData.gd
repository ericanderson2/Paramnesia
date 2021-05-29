extends Node

export var max_health = 100
export var max_food = 100
export var max_water = 100
export var damage = 20

signal coins_changed
signal day_changed
signal inventory_updated
signal time_advanced

var inventory = []
var holding = 0 setget set_holding
var level = 2
var coins: int = 0 setget set_coins
var max_slots: int = 24
var day: int = 1 setget set_day
var season: String = "Summer"
var time_of_day: float = 0

var hair: int = 1
var outfit: int = 1
var skin_color: Color = Color("#f0b577")
var hair_color: Color = Color("#8d3d21")
var brow_color: Color = Color("#261604")
var eye_color: Color = Color("#143eae")

func _ready():
	initialize()
# warning-ignore:return_value_discarded
	self.connect("inventory_updated", MissionController, "player_inventory_changed")

func initialize():
	coins = 0
	holding = 0
	level = 1
	inventory = []
	
	#debug items:
	add_item(ItemStack.new("bola", 5))
	add_item(ItemStack.new("stone_axe", 1))
	add_item(ItemStack.new("wood", 500))
	add_item(ItemStack.new("stone", 200))
	add_item(ItemStack.new("stone_axe", 1))

func _process(delta):
	var prev_time = time_of_day
	time_of_day += delta / 5
	
	if ceil(prev_time) == floor(time_of_day):
		emit_signal("time_advanced", int(time_of_day))
	
	if time_of_day > 24:
		set_day(day + 1)
		time_of_day = 0

func pop_item_at_slot(slot: int):
	if slot > inventory.size() - 1:
		return null
	var item = inventory[slot]
	inventory.remove(slot)
	emit_signal("inventory_updated")
	return item

func get_item_at_slot(slot: int):
	if slot > inventory.size() - 1:
		return null
	var item = inventory[slot]
	return item

func insert_at_slot(slot: int, item: Object):
	if inventory.size() < max_slots:
		inventory.insert(slot, item)
	else:
		#drop items
		pass
	emit_signal("inventory_updated")

func set_holding(value):
	holding = value
	emit_signal("inventory_updated")

func remove_item(id: String) -> bool:
	for slot in inventory:
		if slot.id == id:
			slot.amount -= 1
			if slot.amount == 0:
				inventory.erase(slot)
			emit_signal("inventory_updated")
			return true
	return false

func add_item(item: ItemStack):
	
	var stack_size: int = ItemDictionary.get_item(item.id)["stack"]
	var id: String = item.id
	var num: int = item.amount
	
	for i in range(max_slots):
		if i >= inventory.size():
			if num > stack_size:
				num -= stack_size
				inventory.append(ItemStack.new(id, stack_size))
			else:
				inventory.append(ItemStack.new(id, num))
				num = 0
				break
		if inventory[i].id == id:
			if inventory[i].room_left_in_stack() < num:
				num -= inventory[i].room_left_in_stack()
				inventory[i].amount += inventory[i].room_left_in_stack()
			else:
				inventory[i].amount += num
				num = 0
				break

	emit_signal("inventory_updated")
	if num > 0:
		return ItemStack.new(id, num)
	else:
		return null

func set_primary(slot: int):
	if slot > inventory.size() - 1:
		return
	if slot != 0:
		var temp_item = inventory[0]
		inventory[0] = inventory[slot]
		inventory[slot] = temp_item
	emit_signal("inventory_updated")

func set_secondary(slot: int):
	if slot > inventory.size() - 1:
		return
	if slot != 1:
		var temp_item = inventory[1]
		inventory[1] = inventory[slot]
		inventory[slot] = temp_item
	emit_signal("inventory_updated")

func set_slot(slot: int, item: Object):
	if slot > inventory.size() - 1:
		return
	inventory[slot] = item
	emit_signal("inventory_updated")

func add_without_stacking(item: Object):
	if inventory.size() >= max_slots:
		emit_signal("inventory_updated")
		return item
	inventory.append(item)
	emit_signal("inventory_updated")
	return null

func get_item_held():
	if holding > inventory.size() - 1:
		return null
	else:
		return inventory[holding]

func set_coins(value: int):
	coins = value
	emit_signal("coins_changed")

func set_day(value: int):
	day = value
	emit_signal("day_changed")
