extends Node2D

onready var boat = get_node("Boat")

var fisher: Object

func _ready():
	set_physics_process(false)
	boat.connect("boat_entered", self, "begin_trial")
	boat.connect("destroyed", self, "mission_failed")
	boat.dir = Vector2(0, -1)
	boat.invincible = true

func start(passed_fisher: Object):
	fisher = passed_fisher
	fisher.get_parent().remove_child(fisher)
	boat.get_node("YSort/SecondRider").add_child(fisher)
	fisher.CAN_INTERACT = false
	
	fisher.global_position = boat.get_node("YSort/SecondRider").global_position
	
	fisher.set_physics_process(false)
	
	boat.can_interact = true
	set_physics_process(true)

func begin_trial():
	boat.can_interact = false
	get_node("Fin").started = true
	boat.invincible = false
	get_node("BoatBlock").queue_free()

func _physics_process(_delta):
	fisher.set_direction(boat.dir)

func mission_failed():
	set_physics_process(false)
	get_node("Fin").started = false
	
	fisher.CAN_INTERACT = true
	fisher.set_physics_process(true)
	fisher.get_parent().remove_child(fisher)
	get_tree().get_current_scene().get_node("GlobalYSort/Mobs").call_deferred("add_child", fisher)
	fisher.global_position = get_node("FisherPosition").global_position
	
	if boat.riding:
		get_tree().get_current_scene().get_node("GlobalYSort/Player").stop_riding()
	get_tree().get_current_scene().get_node("GlobalYSort/Player").set_deferred("global_position", fisher.global_position + Vector2(20, 0))
	
	boat.queue_free()
	
	get_tree().get_current_scene().get_node("GUI").add_child(load("res://Effects/Fade/FadeEffect.tscn").instance())
	
	remove_from_group("Mission1")
	fisher.call_deferred("arrived_at_location", Global.buildings["Lake"])
	
	queue_free()
