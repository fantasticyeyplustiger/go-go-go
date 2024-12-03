extends Node2D

@export var rows : int = 0
@export var columns : int = 0
@export var bpm : float

@onready var audio = $Music

var tile_size = 256

var start_music : bool = true
var start_wave : bool = true

var row_attacks
var column_attacks

var down_row_start : Vector2
var up_row_start : Vector2
var right_col_start : Vector2
var left_col_start : Vector2

var spawn_positions : Array[Vector2] = []
var local_positions : Array[Vector2] = []
var current_events : Array

var beat_length : float
var song_length : float
var total_beats : int
var current_beat : int = 0

var data = Globals.levelData.new()
var debug_vector : Vector2 = Vector2(-1, -1)

var first_wave : bool = true

var boulder = preload("res://Obstacles/Boulder.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data._load("res://SavedLevels/MR OOPS HARD MODE")
	
	down_row_start = $DownRowStart.position
	up_row_start = $UpRowStart.position
	right_col_start = $RightColumnStart.position
	left_col_start = $LeftColumnStart.position
	song_length = $Music.stream.get_length()
	
	spawn_at(down_row_start, tile_size, 0, rows + 1)
	spawn_at(up_row_start, tile_size, 0, 0)
	spawn_at(right_col_start, 0, tile_size, columns + 1)
	spawn_at(left_col_start, 0, tile_size, 0)
	
	init_play_timer()

func _physics_process(delta: float) -> void:
	pass

func play() -> void:
	
	if first_wave:
		$Music.play()
		first_wave = false
	
	current_events = data._get_events(current_beat)
	
	if current_events.is_empty():
		return
	
	var event_position : Vector2
	var spawn_position : Vector2
	var obstacle
	
	for event in current_events:
		
		obstacle = get_obstacle(event)
		
		event_position = Vector2(event.x, event.y)
		
		spawn_position = get_spawn_position(event_position)
		
		if event.x > 0 and event.y == 0:
			obstacle.direction = Globals.directions.DOWN
		
		elif event.x > 0 and event.y == columns + 1:
			obstacle.direction = Globals.directions.UP
		
		elif event.x == 0 and event.y > 0:
			obstacle.direction = Globals.directions.LEFT
		
		else: #elif event.x == rows + 1 and event.y > 0:
			obstacle.direction = Globals.directions.RIGHT
		
		obstacle.global_position = spawn_position
		event.activated = true
		
		print(obstacle.global_position)
	
	
	current_beat += 1

func get_obstacle(event):
	
	var obstacle_type = get_obstacle_type(event.type)
	
	match obstacle_type:
		
		Globals.obstacle_types.BOULDER:
			var a_boulder = boulder.instantiate()
			a_boulder.initialize()
			return a_boulder
		
		# add return instantiated scene accordingly
		Globals.obstacle_types.ROCK_PELLET:
			pass
		
		Globals.obstacle_types.STEEL_BALL:
			pass
		
		Globals.obstacle_types.IRON_PELLET:
			pass

func get_obstacle_type(type) -> Globals.obstacle_types:
	for i in Globals.obstacle_types.keys().size():
		if type == i:
			i = i as Globals.obstacle_types
			return i
	
	return Globals.obstacle_types.BOULDER


func get_spawn_position(local_position : Vector2) -> Vector2:
	
	var index = local_positions.find(local_position, 0)
	
	return spawn_positions[index]


func init_play_timer() -> void:
	beat_length = (60 / bpm)
	total_beats = song_length / beat_length
	$PlayTimer.wait_time = beat_length


func spawn_at(start_pos : Vector2, x_add : int, y_add : int, constant : int) -> void:
	
	for i in rows:
		
		var spawn_pos : Vector2 = Vector2((x_add * i), (y_add * i))
		spawn_pos += start_pos + Vector2(x_add, y_add)
		
		spawn_positions.append(spawn_pos)
	
	init_local_positions(x_add == 0, constant)
	


func init_local_positions(constant_is_x : bool, constant : int) -> void:
	if constant_is_x:
		for i in columns:
			local_positions.append(Vector2(constant, i + 1))
	
	else:
		for i in rows:
			local_positions.append(Vector2(i + 1, constant))


func start_level() -> void:
	$BG1.visible = false
	$PlayTimer.start(3)
	
