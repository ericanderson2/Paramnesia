extends Control

onready var inventory_button = get_node("InventoryButton")
onready var crafting_button = get_node("CraftingButton")
onready var inventory_tab = get_node("Inventory")
onready var crafting_tab = get_node("Crafting")

func _ready():
	inventory_button.disabled = true
	crafting_button.disabled = false
	
	inventory_tab.visible = true
	inventory_tab.set_process_input(true)
	crafting_tab.visible = false
	crafting_tab.set_process_input(false)
	

func _on_InventoryButton_pressed():
	inventory_button.disabled = true
	crafting_button.disabled = false
	
	inventory_tab.visible = true
	inventory_tab.set_process_input(true)
	crafting_tab.visible = false
	crafting_tab.set_process_input(false)

func _on_CraftingButton_pressed():
	inventory_button.disabled = false
	crafting_button.disabled = true
	
	inventory_tab.visible = false
	inventory_tab.set_process_input(false)
	crafting_tab.visible = true
	crafting_tab.set_process_input(true)
