extends Node2D

@export var direction : Globals.directions = Globals.directions.UP

var boulder = preload("res://Obstacles/Boulder.tscn").instantiate()

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
			

'''
- flashes the arrow sprite a few times
- input: time the arrow should be visible and invisible in seconds
'''
func flash_arrow(arrow_delay : float):
	if arrow_delay <= 0:
		roll_obstacle()
		return
	
	$Arrow.visible = true
	await get_tree().create_timer(arrow_delay)
	$Arrow.visible = false
	await get_tree().create_timer(arrow_delay)
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
	
	boulder.init(direction, Globals.obstacle_types.BOULDER)
	add_child(boulder)
	boulder.global_position = global_position
	
	pass
