extends Control

const required_item = preload("res://GUI/Missions/ItemWithNumbers.tscn")

onready var expand_tween = get_node("ExpandTween")
onready var contract_tween = get_node("ContractTween")

var mission: int
var required: bool = false
var type: String

onready var background = get_node("Background")
onready var descr_label = get_node("Description")
onready var resource_mission = get_node("ResourceMission")
onready var reward = get_node("Reward")
onready var delete = get_node("DeleteButton")

signal expand(node)

func _ready():
	get_node("Title").text = MissionController.MISSIONS[mission]["title"]
	descr_label.text = MissionController.MISSIONS[mission]["description"]
	required = MissionController.MISSIONS[mission]["required"]
	type = mission["type"]
	resource_mission.rect_position.y = descr_label.get_line_count() * 11 + 28
	reward.rect_position.y = descr_label.get_line_count() * 11 + 28
	if mission["reward"] == "item":
		var item_list = mission["reward_items"]
		var x = 40
		for item in item_list:
			var visual = required_item.instance()
			visual.get_node("TextureRect").texture = load(ItemDictionary.get_item(item[0])["icon"])
			visual.get_node("Label").text = "x " + str(item[1])
			reward.add_child(visual)
			visual.rect_position.x += x
			x += 35
	elif mission["reward"] == "blueprint":
		var item = mission["blueprint"]
		var visual = required_item.instance()
		visual.get_node("TextureRect").texture = load(ItemDictionary.get_item(item)["icon"])
		visual.get_node("Label").text = "(blueprint)"
		reward.add_child(visual)
		visual.rect_position.x += 40
	if type == "item":
		var item_list = mission["item_list"]
		var x = 50
		for item in item_list:
			var visual = required_item.instance()
			visual.get_node("TextureRect").texture = load(ItemDictionary.get_item(item[0])["icon"])
			visual.get_node("Label").text = "x " + str(item[1])
			resource_mission.add_child(visual)
			visual.rect_position.x += x
			x += 35
		reward.rect_position.y += 14
	if required:
		get_node("DeleteButton").queue_free()

func _on_DeleteButton_pressed():
	if not required:
		MissionController.delete_mission(mission)
		queue_free()

func collapse():
	if get_node("ExpandButton").pressed:
		get_node("ExpandButton").pressed = false
		do_collapse()

func do_collapse():
	var total_size_y = 46 + descr_label.get_line_count() * 11
	if type == "item":
		total_size_y += 14
	contract_tween.interpolate_property(background, "rect_size", Vector2(320, total_size_y), Vector2(320, 24), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	contract_tween.interpolate_property(self, "rect_min_size", Vector2(0, total_size_y), Vector2(0, 24), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	contract_tween.start()
	descr_label.visible = false
	reward.visible = false
	resource_mission.visible = false
	if not required:
		delete.visible = false

func _on_ExpandButton_toggled(button_pressed):
	if button_pressed:
		emit_signal("expand", self)
		var total_size_y = 46 + descr_label.get_line_count() * 11
		if type == "item":
			total_size_y += 14
		expand_tween.interpolate_property(background, "rect_size", Vector2(320, 24), Vector2(320, total_size_y), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		expand_tween.interpolate_property(self, "rect_min_size", Vector2(0, 24), Vector2(0, total_size_y), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		expand_tween.start()
	else:
		do_collapse()

func _on_ExpandTween_tween_all_completed():
	descr_label.visible = true
	reward.visible = true
	if not required:
		delete.visible = true
	if type == "item":
		resource_mission.visible = true
