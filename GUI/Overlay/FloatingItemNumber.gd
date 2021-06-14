extends Label

var transparency = 1

signal done

func _ready():
	transparency = 0

func _process(delta):
	if transparency > 0:
		transparency -= delta / 4
		transparency = clamp(transparency, 0, 1)
		self.modulate.a = transparency
		if transparency == 0:
			emit_signal("done")

func reset(new_text, trans):
	text = new_text
	transparency = trans
