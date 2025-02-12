extends CharacterBody2D

@export var rotate_speed : float = 0.0
@export var direction : Globals.directions = Globals.directions.UP
@export var obstacle_type : Globals.obstacle_types = Globals.obstacle_types.BOULDER

func change_velocity(new_direction):
	velocity = Globals.obstacle_speed[obstacle_type] * Globals.roll_direction[new_direction]
	$Sprite2D.rotate(rotate_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	move_and_slide()

func die():
	self.queue_free()
