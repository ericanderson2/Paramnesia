extends Control

const item_base = preload("res://GUI/Inventory/ObjectInventory/InventoryItem.tscn")
const item_background = preload("res://GUI/Inventory/ObjectInventory/ItemBackground.tscn")

var max_slots: int = 5
var inventory
var item_size: int = 32
var buffer: int = 10

func redraw():
	Utility.delete_children(self)
	var x = 0
	var y = 0
	for i in range(max_slots):
		var panel = item_background.instance()
		panel.rect_position = Vector2(x, y)
		if i == get_parent().object_hovering:
			panel.set("custom_styles/panel", load("res://GUI/Inventory/yellow_box.tres"))
		add_child(panel)
		x += item_size + buffer
		if x + item_size + buffer > rect_size.x:
			x = 0
			y += item_size + buffer
	x = 4
	y = 4
	for slot in inventory:
		if slot != null:
			var id = slot.id
			var num = slot.amount
			var item = item_base.instance()
			item.get_node("TextureRect").texture = load(ItemDictionary.get_item(id)["icon"])
			if num > 0:
				item.get_node("Label").text = "x " + str(num)
			item.rect_position = Vector2(x, y)
			add_child(item)
			x += item_size + buffer
			if x + item_size + buffer - 4 > rect_size.x:
				x = 4
				y += item_size + buffer

func pop_item_at_pos(cursor_pos: Vector2):
	cursor_pos -= rect_global_position
	var slot = int(cursor_pos.x / (item_size + buffer)) + int(cursor_pos.y / (item_size + buffer)) * int(rect_size.x / (item_size + buffer))
	if slot > inventory.size() - 1:
		return null
	var item = inventory[slot]
	inventory.remove(slot)
	get_parent().object_inventory_updated()
	return item

func add_item(item: Object):
	var id = item.id
	var num = item.amount
	var stack = ItemDictionary.get_item(id)["stack"]
	
	for i in range(max_slots):
		if i >= inventory.size():
			if num > stack:
				num -= stack
				inventory.append(ItemStack.new(id, stack))
			else:
				inventory.append(ItemStack.new(id, num))
				num = 0
				break
		if inventory[i].id == id:
			if inventory[i].amount + num > stack:
				num -= stack - inventory[i].amount
				inventory[i].amount = stack
			else:
				inventory[i].amount = inventory[i].amount + num
				num = 0
				break
	
	get_parent().object_inventory_updated()
	if num > 0:
		return ItemStack.new(id, num)
	else:
		return null

func get_slot_at_pos(cursor_pos: Vector2):
	cursor_pos -= rect_global_position
	var slot = int(cursor_pos.x / (item_size + buffer)) + int(cursor_pos.y / (item_size + buffer)) * int(rect_size.x / (item_size + buffer))
	if slot > max_slots - 1:
		return null
	return slot

func insert_at_slot(slot: int, item: Object):
	if inventory.size() < max_slots:
		inventory.insert(slot, ItemStack.new(item.id, item.amount))
	else:
		#drop items
		pass
	get_parent().object_inventory_updated()
