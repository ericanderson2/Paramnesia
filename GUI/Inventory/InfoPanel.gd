extends Panel

const recipe_item = preload("res://GUI/Inventory/RecipeItem.tscn")

onready var selected = get_node("SelectedItem")
onready var options = get_node("Options")
onready var recipe_box = get_node("SelectedItem/VBoxContainer/Recipe")

func redraw():
	if get_parent().selected == null:
		options.visible  = true
		selected.visible = false
	else:
		options.visible = false
		selected.visible = true
		Utility.delete_children(recipe_box)
		var id = get_parent().selected
		get_node("SelectedItem/Icon").texture = load(ItemDictionary.get_item(id)["icon"])
		get_node("SelectedItem/Item").text = ItemDictionary.get_item(id)["name"]
		get_node("SelectedItem/VBoxContainer/Description").text = ItemDictionary.get_item(id)["description"]
		get_node("SelectedItem/VBoxContainer/Level").text = "Level " + str(ItemDictionary.get_item(id)["level"])
		for item in ItemDictionary.get_item(id)["recipe"]:
			var recipe = recipe_item.instance()
			recipe.get_node("Icon").texture = load(ItemDictionary.get_item(item[0])["icon"])
			recipe.get_node("Amount").text = "x " + str(item[1])
			recipe_box.add_child(recipe)
