extends Control

var num_active_labels = 0
var frame_count = 0

func _process(_delta):
	if num_active_labels > 0:
		frame_count += 1
		if frame_count == 3:
			frame_count = 0
			rect_position = get_tree().get_current_scene().get_node("GlobalYSort/Player").get_global_transform_with_canvas().get_origin()
			rect_position = rect_position - Vector2(21, 47)

func _on_label_done():
	num_active_labels -= 1
