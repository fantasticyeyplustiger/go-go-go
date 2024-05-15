extends Node2D

@export var rows = 0
@export var columns = 0
@export var beats_per_minute = 0

var rng = RandomNumberGenerator.new()
var wave = 1
var attack_rows = 0
var attack_columns = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = 2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

'''
-- GET RANDOM OBSTACLES --
- gets a random number of obstacles to roll down the map
- the higher the wave, the more obstacles there will be
'''
func get_random_obstacles(wave, attack_rows, attack_columns):
	var obstacles = rng.randi_range(1, 3)
	obstacles = obstacles * (wave / 5)
	

#func get_random_row_and_column(wave):
	#attack_rows = rng.randi_range(0, rows)
	#attack_columns = rng.randi_range(0, columns)
	#pass


'''
-- ON RHYTHM --
- spawns obstacles after a certain amount of time has passed
'''
func on_rhythm():
	
	pass # Replace with function body.
