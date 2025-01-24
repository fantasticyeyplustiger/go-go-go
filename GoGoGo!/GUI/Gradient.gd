extends Control

func pulse(speed : float):
	$AnimationPlayer.speed_scale = 1 / speed
	$AnimationPlayer.speed_scale /= 3
	$AnimationPlayer.play("pulse")

'''
Changes color of the gradient.
Must be called before pulse().
'''
func change_color(new_color : Color):
	$Gradient.modulate = new_color

func change_opacity(new_opacity : int, beat_length):
	pass
