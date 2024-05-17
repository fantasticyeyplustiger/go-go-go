extends Node2D

@export var rotate_speed = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$Sprite2D.rotate(rotate_speed)
	pass
