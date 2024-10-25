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
	data._add_event(1,0,Vector2(6,1))
	data._add_event(2,0,Vector2(2,0))
	data._add_event(3,0,Vector2(0,2))
	data._add_event(4,0,Vector2(1,6))
	data._add_event(5,0,Vector2(6,1))
	data._add_event(6,0,Vector2(2,0))
	data._add_event(7,0,Vector2(0,2))
	data._add_event(8,0,Vector2(1,6))
	
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
		if(events[i].timing <= Globals.songMilliseconds && !events[i].activated):
			# all the code below spawns a boulder, change this to a function once we add more obstacles!
			_spawn_obstacle(events[i])
	
	if(Globals.songMilliseconds>nextBeat):
		nextBeat += beatLength
		# on_rhythm()

func _spawn_obstacle(object):
	
	if(object.type==0):
		
		var newBoulder = boulder.instantiate()
		add_child(newBoulder)
		var spawnPosition=object.position
		
		newBoulder.global_position=spawners[spawnPosition.x][spawnPosition.y]
		
		var direction = Globals.directions.RIGHT
		
		if(spawnPosition.x == 6 and spawnPosition.y > 0):
			direction = Globals.directions.LEFT
			newBoulder.global_position.x+=256
		elif(spawnPosition.x > 0 and spawnPosition.y == 6):
			direction = Globals.directions.UP
			newBoulder.global_position.y+=256
		elif(spawnPosition.x > 0 and spawnPosition.y == 0):
			direction = Globals.directions.DOWN
		
		newBoulder.direction=direction
		
		var SFX = newBoulder.find_child("BoulderSFX")
		SFX.play()
		object.activated = true
		print("spawned boulder!")

'''
-- UNHANDLED INPUT --
- respawns the player when they press "R"
'''
func _unhandled_input(_event):
	if Input.is_action_pressed("respawn"):
		get_tree().reload_current_scene()
