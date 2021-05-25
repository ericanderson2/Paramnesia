extends ColorRect

const AMBIENT_NPC = preload("res://Characters/Friendly/TownNPC/Ambient/AmbientNPC.tscn")
var can_spawn: bool = true

func _ready():
	color = Color("00ffffff")

func _physics_process(_delta):
	if rect_global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) > 300 and rect_global_position.distance_to(get_tree().get_current_scene().get_node("GlobalYSort/Player").global_position) < 400:
		if Global.ambient_mobs < 20 and can_spawn:
			spawn_ambient_npc()

func spawn_ambient_npc():
	can_spawn = false
	get_node("Timer").start(rand_range(4.0, 7.0))
	
	var npc = AMBIENT_NPC.instance()
	get_parent().add_child(npc)
	npc.global_position = rect_global_position + Vector2(rand_range(0.0, rect_size.x), rand_range(0.0, rect_size.y))

func _on_Timer_timeout():
	can_spawn = true
