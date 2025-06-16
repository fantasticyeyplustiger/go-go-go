extends Sprite2D

@export var is_laser : bool

func set_wait(wait_time : float) -> void:
	visible = true
	$Timer.wait_time = wait_time
	$AnimationPlayer.speed_scale = 1 / wait_time
	if is_laser:
		$AnimationPlayer.play("turn_laser_visible")
	else:
		$AnimationPlayer.play("turn_visible")
	$Timer.start()

func set_arrow(new_direction : Globals.directions) -> void:
	match new_direction:
		Globals.directions.DOWN:
			set_rotation_degrees(180)
		Globals.directions.RIGHT:
			set_rotation_degrees(90)
		Globals.directions.LEFT:
			set_rotation_degrees(270)


func disappear() -> void:
	self.visible = false
	self.queue_free()
