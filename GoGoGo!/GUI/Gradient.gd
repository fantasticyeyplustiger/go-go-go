extends Control

func pulse():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("pulse")

'''
Changes color of the gradient.
Must be called before pulse().
'''
func change_color(new_color : Color):
	$Gradient.modulate = new_color
