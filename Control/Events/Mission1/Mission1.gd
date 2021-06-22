extends Node2D

onready var boat = get_node("Boat")

var fisher: Object

func _ready():
	set_physics_process(false)
	boat.connect("boat_entered", self, "begin_trial")
	boat.dir = Vector2(0, -1)

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

func _physics_process(_delta):
	fisher.set_direction(boat.dir)
