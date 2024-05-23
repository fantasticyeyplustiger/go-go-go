extends CharacterBody2D

@export var rotate_speed : float = 0.0
@export var direction : Globals.directions = Globals.directions.UP
@export var obstacle_type : Globals.obstacle_types = Globals.obstacle_types.BOULDER

func initialize(dir, obs_type):
	direction = dir
	obstacle_type = obs_type
	pass

func _ready():
	velocity = Globals.obstacle_speed[obstacle_type] * Globals.roll_direction[direction]
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide()
	$Sprite2D.rotate(rotate_speed)
	pass

func on_roll(roll_velocity):
	velocity = roll_velocity

func die():
	pass
