extends Control

func _ready():
	$AnimationPlayer.play("FadeIn")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
