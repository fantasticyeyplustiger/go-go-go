extends AnimatedSprite2D

func switch_sprite(_area: Area2D) -> void:
	self.frame = 1
	$LaserDetector/CollisionShape2D.set_deferred("disabled", true)

func disable_collision() -> void:
	$LaserDetector/CollisionShape2D.set_deferred("disabled", true)
