extends AnimatedSprite2D

'''
Makes sure that this node doesn't change sprites if there is another laser
going in the opposite direction. It should only change sprites if there is a laser
going perpendicular to it.
'''
func change_collision(direction : Globals.directions):
	
	var unique_collision_value : int
	
	var detect_values : Vector2i
	
	# This code is horrible and I don't know how to make it better, but it works.
	match direction:
		Globals.directions.UP:
			unique_collision_value = 6
			detect_values = Vector2i(8, 9)
		Globals.directions.DOWN:
			unique_collision_value = 7
			detect_values = Vector2i(8, 9)
		Globals.directions.LEFT:
			unique_collision_value = 8
			detect_values = Vector2i(6, 7)
		Globals.directions.RIGHT:
			unique_collision_value = 9
			detect_values = Vector2i(6, 7)
	
	$LaserDetector.set_collision_layer_value(unique_collision_value, true)
	$LaserDetector.set_collision_mask_value(detect_values.x, true)
	$LaserDetector.set_collision_mask_value(detect_values.y, true)
	

func switch_sprite(_area: Area2D) -> void:
	self.frame = 1

func disable_collision() -> void:
	$LaserDetector/CollisionShape2D.set_deferred("disabled", true)

func switch_to_normal(_area: Area2D) -> void:
	self.frame = 0
