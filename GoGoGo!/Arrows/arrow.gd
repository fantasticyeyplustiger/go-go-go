extends Sprite2D

func set_wait(wait_time : float) -> void:
	$Timer.wait_time = wait_time
	$AnimationPlayer.speed_scale = wait_time
	$AnimationPlayer.play("turn_visible")
	$Timer.start()

func set_arrow(new_direction : Globals.directions) -> void:
	match new_direction:
		Globals.directions.DOWN:
			flip_v = true
		Globals.directions.RIGHT:
			set_rotation_degrees(90)
		Globals.directions.LEFT:
			set_rotation_degrees(270)


func disappear() -> void:
	self.visible = false
	self.queue_free()
