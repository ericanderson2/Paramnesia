extends Control

const item_base = preload("res://GUI/Inventory/ObjectInventory/InventoryItem.tscn")
const item_background = preload("res://GUI/Inventory/ObjectInventory/ItemBackground.tscn")

var item_size: int = 32
var buffer: int = 10

func redraw():
	Utility.delete_children(self)
	var x = 4
	var y = 4
	for i in range(PlayerData.max_slots):
		var panel = item_background.instance()
		panel.rect_position = Vector2(x - 4, y - 4)
		if i == 0:
			panel.set("custom_styles/panel", load("res://GUI/Inventory/purple_box.tres"))
		elif i == 1:
			panel.set("custom_styles/panel", load("res://GUI/Inventory/blue_box.tres"))
		if i == get_parent().get_parent().hovering or i == get_parent().get_parent().selected_slot:
			panel.set("custom_styles/panel", load("res://GUI/Inventory/yellow_box.tres"))
		add_child(panel)
		
		if i < PlayerData.inventory.size():
			var id = PlayerData.get_item_at_slot(i).id
			var num = PlayerData.get_item_at_slot(i).amount
			var item = item_base.instance()
			item.get_node("TextureRect").texture = load(ItemDictionary.get_item(id)["icon"])
			if num > 0:
				item.get_node("Label").text = "x " + str(num)
			item.rect_position = Vector2(x, y)
			add_child(item)
		
		rect_min_size.y = y + item_size + buffer - 3
		x += item_size + buffer
		if x + item_size + buffer - 4 > rect_size.x:
			x = 4
			y += item_size + buffer

func slot_center_location(slot: int):
	var x = 4
	var y = 4
	for _i in range(slot):
		x += item_size + buffer
		if x + item_size + buffer - 4 > rect_size.x:
			x = 4
			y += item_size + buffer
# warning-ignore:integer_division
# warning-ignore:integer_division
	return Vector2(x + item_size / 2, y + item_size / 2)

func get_slot_at_pos(cursor_pos: Vector2):
	cursor_pos -= rect_global_position
	var slot = int((cursor_pos.x + 0) / (item_size + buffer)) + int(cursor_pos.y / (item_size + buffer)) * int(rect_size.x / (item_size + buffer))
	return slot
