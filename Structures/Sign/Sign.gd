extends StaticStructure

export var text: String = "" setget set_text
export var id: int = 1

func extra_init():
	get_node("Label").text = text
	get_node("Label").visible = false

func enter_mouse():
	get_node("Label").visible = true

func exit_mouse():
	get_node("Label").visible = false

func set_text(passed_text):
	text = passed_text
	get_node("Label").text = text
