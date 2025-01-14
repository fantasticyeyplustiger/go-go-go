extends AnimatedSprite2D

'''
Makes sure that this node doesn't change sprites if there is another laser
going in the opposite direction. It should only change sprites if there is a laser
going perpendicular to it.
'''
func change_collision(new_collision_value : int):
	
	# MAKE A TABLE OF VALUES FOR THIS ACCORDINGLY
	
	$LaserDetector.set_collision_layer_value(8, false)
	$LaserDetector.set_collision_mask_value(8, false)
	
	$LaserDetector.set_collision_layer_value(9, true)
	$LaserDetector.set_collision_mask_value(9, true)
	
	

func switch_sprite(_area: Area2D) -> void:
	self.frame = 1

func disable_collision() -> void:
	$LaserDetector/CollisionShape2D.set_deferred("disabled", true)

func switch_to_normal(_area: Area2D) -> void:
	self.frame = 0
