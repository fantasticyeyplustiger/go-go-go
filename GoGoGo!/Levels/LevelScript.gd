extends Node2D

@export var rows : int = 0
@export var columns : int = 0
@export var row_attack_spot_limit : int = 0
@export var column_attack_spot_limit : int = 0

var wave = 0

var row_attacks
var column_attacks

# -1 = left or up, 1 = right or down
var spawn_left_or_right : Array[int] = [0, 0, 0, 0, 0, 0]
var spawn_up_or_down : Array[int] = [0, 0, 0, 0, 0, 0]

func _ready():
	$Timer.start()
	pass

'''
-- GET AMOUNT OF ATTACKS --
- gets the amount of attacks to send for this wave
- input: wave (the higher the wave, the more likely more obstacles will come)
'''
func get_amount_of_attacks(wave, row_or_column_limit):
#endregion
	
	var possible_attack_spots : int
	
	if wave >= 15:
		possible_attack_spots = 4
	elif wave >= 10:
		possible_attack_spots = 3
	elif wave >= 5:
		possible_attack_spots = 2
	else:
		return 1
	
	# makes it so you won't happen to get 1 obstacle in like wave 100 or something
	var wave_spawn_booster : int = (wave / 20) - 1
	
	if wave_spawn_booster >= possible_attack_spots:
		return possible_attack_spots
	
	var attack_spots = randi_range(wave_spawn_booster, possible_attack_spots)
	return attack_spots

func get_random_number(lower_bound : int, upper_bound : int):
	var random_number = randi_range(lower_bound, upper_bound)
	return random_number

func get_attack():
	
	var random_spawn = 0
	var row_limit_breaker = 0
	var column_limit_breaker = 0
	
	for i in spawn_left_or_right:
		if row_limit_breaker > row_attacks:
			break
		
		random_spawn = get_random_number(-1, 1)
		spawn_left_or_right[i] = random_spawn
		row_limit_breaker += 1
		
	for i in spawn_up_or_down:
		if column_limit_breaker > column_attacks:
			break
		
		random_spawn = get_random_number(-1, 1)
		spawn_up_or_down[i] = random_spawn
		
		if random_spawn == 0:
			continue
		
		column_limit_breaker += 1

func attack():
	
	for i in spawn_left_or_right:
		
		match spawn_left_or_right[i]:
			-1: # spawn an obstacle and roll it to the left
				get_node("LeftSpawners/LeftSpawner" + str(i + 1)).flash_arrow(0.5)
			1: # spawn an obstacle and roll it to the right
				get_node("RightSpawners/RightSpawner" + str(i + 1)).flash_arrow(0.5)
	
	for i in spawn_up_or_down:
		
		match spawn_up_or_down[i]:
			-1:
				get_node("UpSpawners/UpSpawner" + str(i + 1)).flash_arrow(0.5)
			1:
				get_node("DownSpawners/DownSpawner" + str(i + 1)).flash_arrow(0.5)
	pass



func on_rhythm():
	
	row_attacks = get_amount_of_attacks(wave, row_attack_spot_limit)
	column_attacks = get_amount_of_attacks(wave, column_attack_spot_limit)
	
	get_attack()
	attack()
	
	wave += 1
