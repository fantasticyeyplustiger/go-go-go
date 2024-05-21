extends CharacterBody2D

@export var rotate_speed = 0.0

func _ready():
	Globals.connect("roll_obstacle", on_roll)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide()
	$Sprite2D.rotate(rotate_speed)
	pass

func on_roll(roll_velocity):
	velocity = roll_velocity
