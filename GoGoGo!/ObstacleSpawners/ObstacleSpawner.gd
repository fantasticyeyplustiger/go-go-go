extends Node2D

@export var direction : Globals.directions = Globals.directions.UP

var boulder = preload("res://Obstacles/Boulder.tscn")

var boulder_added : bool = false

var spawnTime=30

var canAttack : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	match direction:
		Globals.directions.DOWN:
			$Arrow.play("down_arrow")
			
		Globals.directions.LEFT:
			$Arrow.play("left_arrow")
			
		Globals.directions.RIGHT:
			$Arrow.play("right_arrow")
			
		Globals.directions.UP:
			$Arrow.play("up_arrow")
			

func _physics_process(delta):
	if(canAttack):
		$Arrow.visible = !$Arrow.visible
		if(Globals.songMilliseconds>=spawnTime):
			roll_obstacle()
			canAttack=false
	else:
		$Arrow.visible = false

'''
- flashes the arrow sprite a few times
- input: time the arrow should be visible and invisible in seconds
'''
func flash_arrow(arrow_delay : float):
	if arrow_delay <= 0:
		$Arrow.visible = false
		return
	
	$Arrow.visible = !$Arrow.visible
	await get_tree().create_timer(arrow_delay).timeout
	flash_arrow(arrow_delay - 0.1)

'''
var obj = preload(copy path).instantiate()
add_child(obj)
obj.global_position = pos
'''

'''
- clones an obstacle and rolls in a specific direction
'''
func roll_obstacle():
	
	var newBoulder = boulder.instantiate()
	
	newBoulder.initialize(direction, Globals.obstacle_types.BOULDER)
	newBoulder.global_position = global_position
	
	$BoulderSFX.play()
