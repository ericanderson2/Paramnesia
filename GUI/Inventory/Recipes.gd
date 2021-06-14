extends Control

const item_base = preload("res://GUI/Inventory/ObjectInventory/InventoryItem.tscn")
const item_background = preload("res://GUI/Inventory/ObjectInventory/ItemBackground.tscn")

var item_size: int = 32
var buffer: int = 10
var sort_mode: String = "default" setget set_sort

var items: Array = []
var active_array: Array = []

func _ready():
	for item in ItemDictionary.ITEMS:
		if ItemDictionary.get_item(item)["craftable"]:
			items.append(item)
	active_array = items.duplicate()

func redraw():
	Utility.delete_children(self)
	var selected = get_parent().get_parent().selected
	var x = 4
	var y = 4
	for item in active_array:
		var panel = item_background.instance()
		panel.rect_position = Vector2(x - 4, y - 4)
		if item == selected:
			panel.set("custom_styles/panel", load("res://GUI/Inventory/yellow_box.tres"))
		add_child(panel)
			
		var recipe = item_base.instance()
		recipe.get_node("TextureRect").texture = load(ItemDictionary.get_item(item)["icon"])
		recipe.rect_position = Vector2(x, y)
		add_child(recipe)
		rect_min_size.y = y + item_size + buffer - 3
		x += item_size + buffer
		if x + item_size + buffer - 4 > rect_size.x:
			x = 4
			y += item_size + buffer

func get_item_at_location(cursor_pos: Vector2):
	cursor_pos -= rect_global_position
	cursor_pos.y += get_parent().scroll_vertical
	var slot = int((cursor_pos.x + 0) / (item_size + buffer)) + int(cursor_pos.y / (item_size + buffer)) * int(rect_size.x / (item_size + buffer))
	if slot <= items.size() - 1:
		return active_array[slot]
	else:
		return null

func set_sort(mode):
	sort_mode = mode
	match sort_mode:
		"default":
			active_array = items.duplicate()
		"level":
			active_array = items.duplicate()
		"alphabetical":
			active_array = items.duplicate()
			active_array.sort()
	redraw()
