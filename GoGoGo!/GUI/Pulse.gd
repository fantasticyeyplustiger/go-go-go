extends Control

func pulse_left():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("pulse_left")

func pulse_right():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("pulse_right")
