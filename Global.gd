extends Node

var config_path = "res://game.ini"
var save_path = "C:/Users/Eric/Desktop/Paramnesia/saves/"
var config_file

var keybinds = {}
var audio = {}

var embark_loot_table: LootTable
var shop_loot_table: MultiPoolLootTable
var horse_seller_loot_table: MultiPoolLootTable
var current_world
var current_interior
var ambient_mobs: int = 0

var buildings: Dictionary = {
	"Lake" : Vector2(-870, -375)
}

onready var escape_menu = load("res://GUI/EscapeMenu/EscapeMenu.tscn")
onready var console = load("res://GUI/Console/Console.tscn")

enum {
	EASY,
	NORMAL,
	HARD
}

var difficulty = NORMAL
var starting_items = {
	"cow": 0,
	"pig": 0,
	"sheep": 0,
	"goat": 0,
	"chicken": 0,
	"rabbit": 0,
	"wood": 0,
	"stone": 0,
	"fiber": 0,
	"metal": 0,
	"obsidian": 0,
	"coin": 0,
	"construction": 0,
	"farming": 0,
	"trading": 0,
	"foraging": 0
}

var game_paused: bool = false
var current_scene
var block_escape: bool = true
var debug_show_path_grid: bool = false
var debug_show_paths: bool = true
var do_day_cycle: bool = false
var input_locked: bool = false

var num_interacted_with: int = 0

func _ready():
	
	config_file = ConfigFile.new()
	if config_file.load(config_path) == OK:
		for key in config_file.get_section_keys("keybinds"):
			var key_value = config_file.get_value("keybinds", key)
			keybinds[key] = key_value
		for key in config_file.get_section_keys("audio"):
			var key_value = config_file.get_value("audio", key)
			audio[key] = key_value
	else:
		print("game.ini is missing")
		get_tree().quit()
	
	load_loot_tables()
	
	current_scene = get_tree().get_current_scene()
	
	#set_game_binds()

func load_loot_tables():
	embark_loot_table = LootTable.new(load_json("res://Data/EmbarkLootTable.json"))
	shop_loot_table = MultiPoolLootTable.new(load_json("res://Data/Shop1LootTable.json"))
	horse_seller_loot_table = MultiPoolLootTable.new(load_json("res://Data/HorseSellerLootTable.json"))

func load_json(file_path):
	var data_file = File.new()
	data_file.open(file_path, File.READ)
	var json_data = JSON.parse(data_file.get_as_text())
	data_file.close()
	return json_data.result

func _input(event):
	if event is InputEventKey:
		#this needs to be rewritten very badly lmao
		if event.pressed and not event.echo and not block_escape:
			if event.scancode == KEY_ESCAPE and get_tree().get_current_scene().key == "Menu":
				get_tree().get_current_scene().back()
			if event.scancode == KEY_ESCAPE and get_tree().get_current_scene().key != "Menu" and get_tree().get_current_scene().get_node("GUI").close_open_window() and not block_escape:
				get_tree().get_root().add_child(escape_menu.instance())
				get_tree().paused = true
			elif event.scancode == KEY_TAB and get_tree().get_current_scene().key != "Menu":
				get_tree().get_root().add_child(console.instance())
				get_tree().paused = true
	block_escape = false

func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		var action_list = InputMap.get_action_list(key)
		if !action_list.empty():
			InputMap.action_erase_event(key, action_list[0])
		
		var new_key = InputEventKey.new()
		new_key.set_scancode(value)
		InputMap.action_add_event(key, new_key)

func switch_scene(scene: String, do_load: bool = false):
	call_deferred("_deferred_goto_scene", scene, do_load)

func _deferred_goto_scene(scene: String, do_load: bool):
	current_scene.free()
	var path
	match scene:
		"MainMenu":
			path = "res://GUI/MainMenu/MainMenu.tscn"
		"WorldSettings":
			path = "res://GUI/Embark/Embark.tscn"
		"Supplies":
			path = "res://GUI/Embark/Supplies.tscn"
		"CharacterCustomize":
			path = "res://GUI/Embark/CharacterCustomize.tscn"
		"Test1":
			path = "res://World/Scenes/Test1.tscn"
		_:
			path = scene
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	if do_load:
		load_game(scene)
	else:
		if get_tree().get_current_scene().has_method("initialize"):
			get_tree().get_current_scene().initialize()

func save_game(scene: String):
	if scene == "Interior":
		call_deferred("_deferred_exit_interior")
		call_deferred("save_game", current_world.key)
		return
	
	var save_game = File.new()
	var path = save_path + scene + ".save"
	save_game.open(path, File.WRITE)
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:

		if node.filename.empty():
			print("'%s' is not instanced" % node.name)
			continue

		if !node.has_method("save"):
			print("'%s' has no save method" % node.name)
			continue

		var node_data = node.call("save")
		save_game.store_line(to_json(node_data))
	save_game.close()

func load_game(scene: String):
	var save_game = File.new()
	var path = save_path + scene + ".save"
	if not save_game.file_exists(path):
		print("no save file")
		return
		
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if i.get_filename() != "res://Player/Player.tscn":
			i.queue_free()
		
	save_game.open(path, File.READ)
	var scene_root = get_tree().get_current_scene()
	while save_game.get_position() < save_game.get_len():
		
		var node_data = parse_json(save_game.get_line())
		
		var new_object
		if node_data["id"] == "player":
			scene_root.get_node("GlobalYSort/Player").update_from_save(node_data)
		else:
			new_object = load(node_data["filename"]).instance()
			scene_root.get_node("GlobalYSort/World").add_child(new_object)
			new_object.load_from_save(node_data)
		for i in node_data.keys():
			if i == "filename":
				continue
			#new_object.set(i, node_data[i])
	
	scene_root.load_from_save()

	save_game.close()

func enter_interior(path: String):
	call_deferred("_deferred_enter_interior", path)

func _deferred_enter_interior(path: String):
	current_world = get_tree().get_current_scene()
	get_tree().get_root().remove_child(current_world)
	
	var s = ResourceLoader.load(path)
	current_interior = s.instance()
	get_tree().get_root().add_child(current_interior)
	get_tree().set_current_scene(current_interior)

func exit_interior():
	call_deferred("_deferred_exit_interior")

func _deferred_exit_interior():
	if current_interior != null:
		current_interior.queue_free()
		current_interior = null
	
	get_tree().get_root().add_child(current_world)
	get_tree().set_current_scene(current_world)

func update_config():
	for key in audio.keys():
		var key_value = audio[key]
		config_file.set_value("audio", key, key_value)
	config_file.save(config_path)
