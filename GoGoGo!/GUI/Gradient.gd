extends Control

func pulse():
	$AnimationPlayer.play("pulse")

'''
Changes color of the gradient.
Must be called before pulse().
'''
func change_color(new_color : Color):
	$Gradient.modulate = new_color
