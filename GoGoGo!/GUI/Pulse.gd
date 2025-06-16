extends Control


func set_anim_speed(speed : float) -> void:
	$AnimationPlayer.speed_scale = speed

func pulse_left():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("pulse_left")

func pulse_right():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("pulse_right")

func destroy_self(_anim_name: StringName) -> void:
	hide()
	queue_free()
