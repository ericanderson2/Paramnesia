class_name ObjectInventory

extends Control

onready var player = get_node("Player/PlayerInventory")
onready var object = get_node("ObjectInventory")
onready var dropdown = get_node("DropDownMenu")
onready var line_edit = get_node("DropDownMenu/LineEdit")

export var inventory: Array = []
export var can_deposit: bool = true
export var max_slots: int = 5

var item_held = null
var hovering = null
var object_hovering = null
var selected_slot: int = -1

signal inventory_changed

func _ready():
	object.max_slots = max_slots
	object.inventory = inventory
# warning-ignore:return_value_discarded
	PlayerData.connect("inventory_updated", self, "redraw")
	redraw()

func _input(_event):
	var cursor_pos = get_global_mouse_position()
	if player.get_global_rect().has_point(cursor_pos):
		hovering = player.get_slot_at_pos(cursor_pos)
	elif not (dropdown.get_global_rect().has_point(cursor_pos) or line_edit.get_global_rect().has_point(cursor_pos)):
		hovering = null
	if object.get_global_rect().has_point(cursor_pos):
		object_hovering = object.get_slot_at_pos(cursor_pos)
	else:
		object_hovering = null
	if selected_slot != -1:
		hovering = null

	if Input.is_action_just_pressed("inventory_main"):
		if dropdown.visible:
			if dropdown.get_global_rect().has_point(cursor_pos) or line_edit.get_global_rect().has_point(cursor_pos):
				return
			else:
				close_dropdown()
		if player.get_global_rect().has_point(cursor_pos) and can_deposit:
			var slot = player.get_slot_at_pos(cursor_pos)
			var item = PlayerData.pop_item_at_slot(slot)
			if item != null:
				var remainder = object.add_item(item)
				if remainder != null:
					PlayerData.insert_at_slot(slot, remainder)
		elif object.get_global_rect().has_point(cursor_pos):
			var slot = object.get_slot_at_pos(cursor_pos)
			var item = object.pop_item_at_pos(cursor_pos)
			if item != null:
				var remainder = PlayerData.add_item(item)
				if remainder != null:
					object.insert_at_slot(slot, remainder)
	if Input.is_action_just_pressed("inventory_alt"):
		if dropdown.visible and not (dropdown.get_global_rect().has_point(cursor_pos) or line_edit.get_global_rect().has_point(cursor_pos)):
			close_dropdown()
		if player.get_global_rect().has_point(cursor_pos):
			var slot = player.get_slot_at_pos(cursor_pos)
			var item = PlayerData.get_item_at_slot(slot)
			if item != null:
				selected_slot = slot
				dropdown.rect_global_position = Vector2(0, 10) + player.slot_center_location(slot) + player.rect_global_position
				if slot > 11:
					dropdown.rect_global_position.y -= dropdown.rect_size.y + 10
				dropdown.visible = true
	redraw()

func redraw():
	player.redraw()
	object.redraw()

func close_dropdown():
	line_edit.visible = false
	dropdown.visible = false
	selected_slot = -1
	redraw()

func _on_PrimaryButton_pressed():
	line_edit.visible = false
	PlayerData.set_primary(selected_slot)
	close_dropdown()

func _on_SecondaryButton_pressed():
	line_edit.visible = false
	PlayerData.set_secondary(selected_slot)
	close_dropdown()

func _on_HalfButton_pressed():
	line_edit.visible = false
	var item = PlayerData.get_item_at_slot(selected_slot)
	var num = item.amount
	var odd_adjustment: int = num % 2
	if num > 1:
		PlayerData.set_slot(selected_slot, ItemStack.new(item.id, num / 2 + odd_adjustment))
		var remainder = PlayerData.add_without_stacking(ItemStack.new(item.id, num / 2))
		if remainder != null:
			PlayerData.add_item(remainder)
	close_dropdown()

func _on_OneButton_pressed():
	line_edit.visible = false
	var item = PlayerData.get_item_at_slot(selected_slot)
	var num = item.amount
	if num > 1:
		PlayerData.set_slot(selected_slot, ItemStack.new(item.id, num - 1))
		var remainder = PlayerData.add_without_stacking(ItemStack.new(item.id, 1))
		if remainder != null:
			PlayerData.add_item(remainder)
	close_dropdown()

func _on_AmountButton_pressed():
	line_edit.text = ""
	line_edit.visible = true
	line_edit.grab_focus()

func _on_LineEdit_text_entered(new_text):
	line_edit.text = ""
	if new_text.is_valid_integer():
		var num = int(new_text)
		var item = PlayerData.get_item_at_slot(selected_slot)
		if num > 0 and num < item.amount:
			var split = item.amount - num
			PlayerData.set_slot(selected_slot, ItemStack.new(item.id, split))
			var remainder = PlayerData.add_without_stacking(ItemStack.new(item.id, num))
			if remainder != null:
				PlayerData.add_item(remainder)
	close_dropdown()

func object_inventory_updated():
	emit_signal("inventory_changed")
