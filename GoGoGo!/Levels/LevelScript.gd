extends Node2D

@export var rows : int = 0
@export var columns : int = 0
@export var row_attack_spot_limit : int = 0
@export var column_attack_spot_limit : int = 0
@export var wave : int = 0
@export var bpm : float

@onready var audio = $Music

var start_music : bool = true
var start_wave : bool = true

var row_attacks
var column_attacks

var nextBeat=0
var beatLength = 0

# -1 = left or up, 1 = right or down
var spawn_left_or_right : Array[int] = [0, 0, 0, 0, 0, 0]
var spawn_up_or_down : Array[int] = [0, 0, 0, 0, 0, 0]


func _ready():
	bpm/=4
	beatLength = (60/bpm)*1000
	pass

func _physics_process(_delta):
	if start_music:
		audio.play()
		start_music = false
	var songMilliseconds = audio.get_playback_position()*1000
	if(songMilliseconds>nextBeat):
		print("beat triggered!")
		nextBeat+=beatLength
		on_rhythm()

func _unhandled_input(_event):
	if Input.is_action_pressed("respawn"):
		get_tree().reload_current_scene()

'''
-- GET AMOUNT OF ATTACKS --
- gets the amount of attacks to send for this wave
- input: wave (the higher the wave, the more likely more obstacles will come)
'''
func get_amount_of_attacks():
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

'''
-- GET ATTACK --
- gets all of the places where obstacles are going to attack
'''
func get_attack():
	
	var random_spawn : int = 0
	
	#these make it so it doesn't fill up all of the spots
	var row_limit_breaker : int = 0
	var column_limit_breaker : int = 0
	
	for i in row_attacks:
		if row_limit_breaker > row_attacks:
			break
		
		random_spawn = get_random_number(0, 5)
		# -1 = obstacle rolls upward, 0 = no obstacle, 1 = obstacle rolls downward
		spawn_left_or_right[random_spawn] = get_random_number(-1, 1)
		
		if not random_spawn == 0:
			row_limit_breaker += 1
		
	for i in column_attacks:
		if column_limit_breaker > column_attacks:
			break
		
		random_spawn = get_random_number(0, 5)
		# -1 = obstacle rolls upward, 0 = no obstacle, 1 = obstacle rolls downward
		spawn_up_or_down[random_spawn] = get_random_number(-1, 1)
		
		if not random_spawn == 0:
			column_limit_breaker += 1

'''
-- ATTACK --
- attacks the places the obstacles are going to attack from get_attack()
'''
func attack():
	
	var arrow_delay = beatLength/8000
	
	if wave > 50:
		arrow_delay = beatLength/8000
	
	for i in spawn_left_or_right.size():
		var spawner_position = str(i + 1)
		
		match spawn_left_or_right[i]:
			-1: # spawn an obstacle and roll it to the left
				var left_spawner = get_node("LeftSpawners/LeftSpawner" + spawner_position)
				left_spawner.flash_arrow(arrow_delay)
			0:
				continue
			1: # spawn an obstacle and roll it to the right
				var right_spawner = get_node("RightSpawners/RightSpawner" + spawner_position)
				right_spawner.flash_arrow(arrow_delay)
	
	for i in spawn_up_or_down.size():
		var spawner_position = str(i + 1)
		
		match spawn_up_or_down[i]:
			-1: # spawn an obstacle and roll it up
				var up_spawner = get_node("UpSpawners/UpSpawner" + spawner_position)
				up_spawner.flash_arrow(arrow_delay)
			0:
				continue
			1: # spawn an obstacle and roll it down
				var down_spawner = get_node("DownSpawners/DownSpawner" + spawner_position)
				down_spawner.flash_arrow(arrow_delay)
	


func reset_attacks(spawn_array):
	for i in spawn_array:
		
		spawn_array[i] = 0

'''
-- ON RHYTHM --
- every X seconds (change in timer node) send out a wave of attacks
'''
func on_rhythm():
	
	$WaveLabel.text = ("Wave: \n" + str(wave))
	
	if start_wave:
		start_music = true
		start_wave = false
	
	print("wave: " + str(wave))
	
	row_attacks = get_amount_of_attacks()
	column_attacks = get_amount_of_attacks()
	
	get_attack()
	attack()
	
	reset_attacks(spawn_left_or_right)
	reset_attacks(spawn_up_or_down)
	
	wave += 1
