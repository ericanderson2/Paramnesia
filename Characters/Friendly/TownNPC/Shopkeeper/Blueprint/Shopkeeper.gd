extends TownNPC

class_name Shopkeeper

export var interface: String

var inventory: Array
var shop: Object

func object_interacted_with():
	var i = load(interface).instance()
	i.inventory = shop.inventory
	get_tree().get_current_scene().set_gui_window(i)
