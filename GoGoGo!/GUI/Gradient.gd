extends Control

func pulse(pulse_color : Color, speed : float):
	$LeftGradient.modulate = pulse_color
	$AnimationPlayer.speed_scale = speed
	$AnimationPlayer.play("pulse")
