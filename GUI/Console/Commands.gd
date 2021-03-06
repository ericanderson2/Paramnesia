extends Node

const command_words = [["teleport", [2]], ["spawn", [1, 3]], ["give_item", [1, 2]], ["debug_hide_paths", [0]], ["debug_show_paths", [0]], ["spawn_trader", [0]], ["day_cycle_on", [0]], ["day_cycle_off", [0]]]
const spawnable_mobs = ["cow", "deer", "wolf"]

func teleport(x_coord, y_coord):
	var x = str2var(x_coord)
	var y = str2var(y_coord)
	if typeof(x) != TYPE_INT or typeof(y) != TYPE_INT:
		return str("-Invalid parameter types (int, int required)-")
	get_tree().get_current_scene().teleport(x, y)
	return str("~Teleporting to (" + str(x) + ", " + str(y) + ")~")

func spawn(obj, x_coord = "-10000", y_coord = "10000"):
	var mob = obj.to_lower()
	x_coord = str2var(x_coord)
	y_coord = str2var(y_coord)
	if typeof(x_coord) != TYPE_INT or typeof(y_coord) != TYPE_INT:
		return str("-Invalid parameter types (int, int required)-")
	if spawnable_mobs.find(mob) < 0:
		return str('-"' + obj + '" is not a valid spawn-')
	get_tree().get_current_scene().spawn_mob(mob, x_coord, y_coord)
	return str("~Spawning " + obj + "~")

func give_item(item_id, num = "1"):
	num = str2var(num)
	item_id = item_id.to_lower()
	if ItemDictionary.get_item(item_id)["type"] == null:
		return str('-"' + item_id + '" is not a valid item-')
	if typeof(num) != TYPE_INT:
		return ('-"' + str(num) + '" is not a whole number-')
	PlayerData.add_item(ItemStack.new(item_id, num))
	return str("~Giving " + str(num) + " " + item_id + " to player~")

func debug_show_paths():
	Global.debug_show_paths = true
	return "~Debug paths shown~"

func debug_hide_paths():
	Global.debug_show_paths = false
	return "~Debug paths hidden~"

func spawn_trader():
	get_tree().get_current_scene().spawn_trader()
	return "~Spawning trader~"

func day_cycle_on():
	Global.do_day_cycle = true
	return "~Day cycle on~"

func day_cycle_off():
	Global.do_day_cycle = false
	return "~Day cycle off~"
