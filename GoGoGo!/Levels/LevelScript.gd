extends Node2D

#region export variables
@export var rows = 0
@export var columns = 0
@export var beats_per_minute = 0
@export var attack_spot_limit = 0

# needed to set spawn positions
# directions are the direction obstacle will roll down
@export var start_up_row = Vector2()
@export var start_down_row = Vector2()
@export var start_left_column = Vector2()
@export var start_right_column = Vector2()
#endregion

#region variables
enum obstacles {NONE, BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET}

const obstacle_speeds = {obstacles.NONE : 0, obstacles.BOULDER : 128, obstacles.ROCK_PELLET : 512,
			obstacles.STEEL_BALL : 256, obstacles.IRON_PELLET : 1024}

var rng = RandomNumberGenerator.new()
var wave = 1
var tile_size = 256

# obstacles will move in that direction when attacking
var attack_right_rows = range(rows)
var attack_left_rows = range(rows)
var attack_up_columns = range(columns)
var attack_down_columns = range(columns)

# obstacles will move in that direction once spawned at that position in the array
var spawn_to_right = []
var spawn_to_left = []
var spawn_to_up = []
var spawn_to_down = []
#endregion

#region obstacle variables
var boulder = preload("res://Obstacles/Boulder.tscn").instantiate()
var steel_ball = preload("res://Obstacles/SteelBall.tscn").instantiate()
var rock_pellet = preload("res://Obstacles/RockPellet.tscn").instantiate()
var iron_pellet = preload("res://Obstacles/IronPellet.tscn").instantiate()
#endregion


func _ready():
	
	#region initializing arrays
	attack_right_rows.resize(rows); attack_left_rows.resize(rows)
	spawn_to_right.resize(rows); spawn_to_left.resize(rows)
	attack_up_columns.resize(columns); attack_down_columns.resize(columns)
	spawn_to_up.resize(columns); spawn_to_down.resize(columns)
	
	array_initializer(attack_right_rows); array_initializer(attack_left_rows)
	array_initializer(attack_up_columns); array_initializer(attack_down_columns)
	
	initialize_obstacle_spawner_positions(rows, spawn_to_left, start_left_column, 0, tile_size)
	initialize_obstacle_spawner_positions(rows, spawn_to_right, start_right_column, 0, tile_size)
	initialize_obstacle_spawner_positions(columns, spawn_to_up, start_up_row, tile_size, 0)
	initialize_obstacle_spawner_positions(columns, spawn_to_down, start_down_row, tile_size, 0)
#endregion
	
	$Timer.wait_time = 2
	$Timer.start()
	pass # Replace with function body.

func array_initializer(array):
	for i in array:
		array.insert(i, 0)

'''
-- INITIALIZE OBSTACLE SPAWNER POSITIONS --
- initializes the positions of every obstacle spawner
- called by ready
'''
func initialize_obstacle_spawner_positions(rows_or_columns, spawn_row_or_column,
			start_row_or_column, x_direction_adder, y_direction_adder):
	
	for i in rows_or_columns:
		
		# because the start of a row / column is the very first and
		# doesn't need anything added to its position
		if i == 0:
			spawn_row_or_column[i] = start_row_or_column
		
		spawn_row_or_column[i] = start_row_or_column + (Vector2(x_direction_adder, y_direction_adder) * (i + 1))

'''
var obj = preload(copy path).instantiate()
add_child(obj)
obj.global_position = pos
'''

'''
-- ATTACK --
- called after the get_attack function
- sends out a wave of attacks and resets the attack rows and columns to obstacles.NONE afterward
'''
func attack():
	
	for i in attack_left_rows:
		if attack_left_rows[i] != 0:
			roll_obstacle_down(-1, 0, attack_left_rows[i], spawn_to_left[i])
	
	for i in attack_right_rows:
		if attack_right_rows[i] != 0:
			roll_obstacle_down(1, 0, attack_right_rows[i], spawn_to_right[i])
	
	for i in attack_down_columns:
		if attack_down_columns[i] != 0:
			roll_obstacle_down(0, -1, attack_down_columns[i], spawn_to_down[i])
	
	for i in attack_up_columns:
		if attack_up_columns[i] != 0:
			roll_obstacle_down(0, 1, attack_up_columns[i], spawn_to_up[i])
	
	wave += 1

func roll_obstacle_down(x_direction, y_direction, obstacle, spawn_location):
	#var boulder = preload("res://Obstacles/Boulder.tscn").instantiate()
	#var steel_ball = preload("res://Obstacles/SteelBall.tscn").instantiate()
	#var rock_pellet = preload("res://Obstacles/RockPellet.tscn").instantiate()
	#var iron_pellet = preload("res://Obstacles/IronPellet.tscn").instantiate()
	
	#var obj = preload(copy path).instantiate()
	#add_child(obj)
	#obj.global_position = pos
	
	match obstacle:
		obstacles.BOULDER:
			roll_specific_obstacle_down(x_direction, y_direction, boulder, spawn_location)
		obstacles.STEEL_BALL:
			roll_specific_obstacle_down(x_direction, y_direction, steel_ball, spawn_location)
		obstacles.IRON_PELLET:
			roll_specific_obstacle_down(x_direction, y_direction, iron_pellet, spawn_location)
		obstacles.ROCK_PELLET:
			roll_specific_obstacle_down(x_direction, y_direction, rock_pellet, spawn_location)
	
	pass

func roll_specific_obstacle_down(x_direction, y_direction, obstacle, spawn_location):
	add_child(obstacle)
	obstacle.global_position = spawn_location
	obstacle.translate(x_direction, y_direction)

#region all "get" functions
'''
-- GET ATTACK --
- gets the places the level is going to attack from for ONE wave
'''
func get_attack(amount_of_attacks):
	
	for attacks in amount_of_attacks:
		
		# left_right and up_down are not the same to prevent confusion
		var left_right = randi_range(0, 1)
		var up_down = randi_range(0, 1)
		
		var vertical_or_horizontal = randi_range(0, 1)
		
		# 0 = left / up, 1 = right / down
		# 0 = horizontal, 1 = vertical
		var attack_spot = get_random_row_or_column(vertical_or_horizontal)
		var obstacle = get_random_obstacle()
		
		if vertical_or_horizontal == 0: # vertical
			
			if up_down == 0: # up
				attack_up_columns[attack_spot] = obstacle
				
			else: # down
				attack_down_columns[attack_spot] = obstacle
		
		else: # horizontal
			
			if left_right == 0: # left
				attack_left_rows[attack_spot] = obstacle
				
			else:
				attack_up_columns[attack_spot] = obstacle

'''
-- GET RANDOM OBSTACLE --
- gets a random obstacle from the obstacles enum and returns it
'''
func get_random_obstacle():
	
	# obstacles {NONE, BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET}
	
	var obstacle = rng.randi_range(1, 4)
	
	return obstacles.keys()[obstacle]

'''
-- GET RANDOM ROW OR COLUMN --
- gets a random row or column and returns it
- input: direction (decides if rows or columns should be returned)
'''
func get_random_row_or_column(direction):
	
	if direction == 0:
		return rng.randi_range(0, rows - 1)
		
	elif direction == 1:
		return rng.randi_range(0, columns - 1)

'''
-- GET AMOUNT OF ATTACKS --
- gets the amount of attacks to send for this wave
- input: wave (the higher the wave, the more likely more obstacles will come)
'''
func get_amount_of_attacks(wave):
#endregion
	
	var possible_attack_spots
	
	if wave >= 20:
		possible_attack_spots = attack_spot_limit
		
	elif wave >= 15:
		possible_attack_spots = attack_spot_limit / 2
		
	elif wave >= 10:
		possible_attack_spots = attack_spot_limit / 3
		
	elif wave >= 5:
		possible_attack_spots = attack_spot_limit / 5
	
	else:
		return 1
	
	# makes it so you won't happen to get 1 obstacle in like wave 100 or something
	var wave_multiplier = wave / 10
	
	if wave_multiplier >= attack_spot_limit:
		return attack_spot_limit
	
	var attack_spots = randi_range(wave_multiplier, possible_attack_spots)
	return attack_spots

'''
-- ON RHYTHM --
- spawns obstacles after a certain amount of time has passed
'''
func on_rhythm():
	
	var amount_of_attacks = get_amount_of_attacks(wave)
	get_attack(amount_of_attacks)
	attack()

