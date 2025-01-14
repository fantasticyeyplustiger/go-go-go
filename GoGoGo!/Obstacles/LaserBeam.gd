extends Node2D

var direction : Globals.directions

func set_timer(wait_time : float):
	$Timer.wait_time = wait_time
	$Timer.start()

func rotate_beam():
	match direction:
		Globals.directions.LEFT:
			self.rotation_degrees = 90
			change_laser_middle_collision(9)
			
		Globals.directions.UP:
			self.rotation_degrees = 180
			change_laser_middle_collision(10)
			
		Globals.directions.RIGHT:
			self.rotation_degrees = 270
			
		# directions.DOWN: Already facing down, so don't rotate.

func play_animation() -> void:
	
	for laser in $Node.get_children():
		laser.disable_collision()
	
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("fade_away")
	

func animation_finished(_anim_name: StringName) -> void:
	self.queue_free()

func change_laser_middle_collision(new_collision_value : int):
	
	# RIGHT and LEFT lasers should never interact with each other,
	# and UP and DOWN lasers should never interact with each other.
	
	for child in $Node.get_children():
		child.change_collision(new_collision_value)
