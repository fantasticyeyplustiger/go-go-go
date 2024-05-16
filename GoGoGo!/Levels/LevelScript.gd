extends Node2D

@export var rows = 0
@export var columns = 0
@export var beats_per_minute = 0

enum obstacles {NONE, BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET}

var rng = RandomNumberGenerator.new()
var wave = 0
var tile_size = 256

var attack_right_rows = []
var attack_left_rows = []
var attack_up_columns = []
var attack_down_columns = []

#region obstacle variables
var bouler = preload("res://Obstacles/Boulder.tscn").instantiate()
var steel_ball = preload("res://Obstacles/SteelBall.tscn").instantiate()
var rock_pellet = preload("res://Obstacles/RockPellet.tscn").instantiate()
var iron_pellet = preload("res://Obstacles/IronPellet.tscn").instantiate()
#endregion



# Called when the node enters the scene tree for the first time.
func _ready():
	
	attack_right_rows.resize(rows)
	attack_left_rows.resize(rows)
	attack_up_columns.resize(columns)
	attack_down_columns.resize(columns)
	
	
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

func attack():
	var amount_of_attacks = randi_range(0, 10)
	
	for attacks in amount_of_attacks:
		var left_right_up_or_down = randi_range(0, 1)
		var vertical_or_horizontal = randi_range(0, 1)
		if vertical_or_horizontal == 0:
			
			pass

func get_random_row_and_column(direction):
	if direction == 0:
		# attack_rows = rng.randi_range(0, rows - 1)
		pass
	elif direction == 1:
		# attack_columns = rng.randi_range(0, columns - 1)
		pass
	#pass

'''
-- ON RHYTHM --
- spawns obstacles after a certain amount of time has passed
'''
func on_rhythm():
	
	pass # Replace with function body.
