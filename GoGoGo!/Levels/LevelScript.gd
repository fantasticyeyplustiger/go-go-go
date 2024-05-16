extends Node2D

@export var rows = 0
@export var columns = 0
@export var beats_per_minute = 0

var rng = RandomNumberGenerator.new()
var wave = 0
var attack_rows = 0
var attack_columns = 0

#region obstacle variables
var bouler = preload("res://Obstacles/Boulder.tscn")
var steel_ball = preload("res://Obstacles/SteelBall.tscn")
var rock_pellet = preload("res://Obstacles/RockPellet.tscn")
var iron_pellet = preload("res://Obstacles/IronPellet.tscn")
#endregion



# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = 2
	pass # Replace with function body.

'''
var obj = preload(copy path).instantiate()
add_child(obj)
obj.global_position = pos
'''


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
