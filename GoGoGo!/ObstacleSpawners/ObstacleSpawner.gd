extends Node2D

@export var direction : Globals.directions = Globals.directions.UP

enum boulder_counts {ONE, TWO}

var rolling_boulder = boulder_counts.ONE

var boulder = preload("res://Obstacles/Boulder.tscn").instantiate()
var boulder2 = preload("res://Obstacles/Boulder.tscn").instantiate()

var boulder_added : bool = false
var boulder_added2 : bool = false

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
		$Arrow.visible = false
		roll_obstacle()
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
	
	if rolling_boulder == boulder_counts.ONE:
	
		boulder.initialize(direction, Globals.obstacle_types.BOULDER)
		if not boulder_added:
			add_child(boulder)
			boulder_added = true
		boulder.global_position = global_position
		
		rolling_boulder = boulder_counts.TWO
	
	else: # boulder2 is required because this spawner can only spawn one boulder at a time
		# otherwise, and level can't grow more difficult
		# if this doesn't exist boulder1 will go back to spawner before it goes through entire map
		
		boulder2.initialize(direction, Globals.obstacle_types.BOULDER)
		if not boulder_added2:
			add_child(boulder2)
			boulder_added2 = true
		boulder2.global_position = global_position
		
		rolling_boulder = boulder_counts.ONE
