extends StaticStructure

var hitched: bool = false
export var id: int = 1

func set_hitch(passed_value: bool):
	if hitched != passed_value:
		hitched = passed_value
		if hitched:
			sprite.frame += 1
		else:
			sprite.frame -= 1

func get_horse_location() -> Array:
	if sprite.frame < 2:
		return [global_position + Vector2(34, 0), Vector2(-1, 0)]
	else:
		return [global_position + Vector2(-34, 0), Vector2(1, 0)]
