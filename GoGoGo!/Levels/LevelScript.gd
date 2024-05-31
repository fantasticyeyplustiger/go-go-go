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

var boulder = preload("res://Obstacles/Boulder.tscn")

var data = Globals.levelData.new()

var spawners = []

var gridSize=7

'''
-- READY --
- initializes some values
'''
func _ready():
	data._add_event(1000,0,Vector2(6,1))
	data._add_event(2000,0,Vector2(2,0))
	data._add_event(3000,0,Vector2(0,2))
	data._add_event(4000,0,Vector2(1,6))
	#data._load_from_string("{\"events\":[{\"timing\":100,\"type\":0}]}")
	bpm /= 4
	beatLength = (60/bpm) * 1000
	for x in gridSize:
		spawners.append([])
		for y in gridSize:
			spawners[x].append(Vector2(128+(x-1)*256,-128+(6-y)*-256))
	gridSize-=1

'''
-- PHYSICS PROCESS --
- starts music, starts the wave, and attacks the player at a set BPM
'''
func _physics_process(_delta):
	if start_music:
		audio.play()
		start_music = false
		
	Globals.songMilliseconds = audio.get_playback_position()*1000
	var events = data.events
	var loopRange = range(0,events.size())
	for i in loopRange:
		if(events[i].timing <= Globals.songMilliseconds&&!events[i].activated):
			# all the code below spawns a boulder, change this to a function once we add more obstacles!
			var newBoulder = boulder.instantiate()
			add_child(newBoulder)
			var spawnPosition=events[i].position
			
			newBoulder.global_position=spawners[spawnPosition.x][spawnPosition.y]
			
			var direction = Globals.directions.RIGHT
			if(spawnPosition.x==6&&spawnPosition.y>0):
				direction = Globals.directions.LEFT
				newBoulder.global_position.x+=256
			elif(spawnPosition.x>0&&spawnPosition.y==6):
				direction = Globals.directions.UP
				newBoulder.global_position.y+=256
			elif(spawnPosition.x>0&&spawnPosition.y==0):
				direction = Globals.directions.DOWN
			
			newBoulder.direction=direction
			
			var SFX = newBoulder.find_child("BoulderSFX")
			SFX.play()
			events[i].activated=true
			print("spawned boulder!")
	
	if(Globals.songMilliseconds>nextBeat):
		nextBeat += beatLength
		# on_rhythm()

'''
-- UNHANDLED INPUT --
- respawns the player when they press "R"
'''
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

'''
-- GET RANDOM NUMBER --
- gets a random number within a range of two integers. doesn't actually need to be a function,
just looks more readable than "randi()"
'''
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
	var spawnTime = nextBeat-beatLength/2
	
	var arrow_delay = 0.3
	
	for i in spawn_left_or_right.size():
		var spawner_position = str(i + 1)
		
		match spawn_left_or_right[i]:
			-1: # spawn an obstacle and roll it to the left
				var left_spawner = get_node("LeftSpawners/LeftSpawner" + spawner_position)
				left_spawner.flash_arrow(arrow_delay)
				left_spawner.spawnTime=spawnTime
				left_spawner.canAttack=true
			0:
				continue
			1: # spawn an obstacle and roll it to the right
				var right_spawner = get_node("RightSpawners/RightSpawner" + spawner_position)
				right_spawner.flash_arrow(arrow_delay)
				right_spawner.spawnTime=spawnTime
				right_spawner.canAttack=true
	
	reset_attacks(spawn_left_or_right)
	
	for i in spawn_up_or_down.size():
		var spawner_position = str(i + 1)
		
		match spawn_up_or_down[i]:
			-1: # spawn an obstacle and roll it up
				var up_spawner = get_node("UpSpawners/UpSpawner" + spawner_position)
				up_spawner.flash_arrow(arrow_delay)
				up_spawner.spawnTime=spawnTime
				up_spawner.canAttack=true
			0:
				continue
			1: # spawn an obstacle and roll it down
				var down_spawner = get_node("DownSpawners/DownSpawner" + spawner_position)
				down_spawner.flash_arrow(arrow_delay)
				down_spawner.spawnTime=spawnTime
				down_spawner.canAttack=true
	
	reset_attacks(spawn_up_or_down)
	

'''
-- RESET ATTACKS --
- resets all the values inside the array to 0 (no obstacle)
'''
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
	
	wave += 1
