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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data._load("res://SavedLevels/MR OOPS HARD MODE")
	
	down_row_start = $DownRowStart.position
	up_row_start = $UpRowStart.position
	right_col_start = $RightColumnStart.position
	left_col_start = $LeftColumnStart.position
	song_length = $Music.stream.get_length()
	
	spawn_at(down_row_start, tile_size, 0, $DownRowStart, 7)
	spawn_at(up_row_start, tile_size, 0, $UpRowStart, 0)
	spawn_at(right_col_start, 0, tile_size, $RightColumnStart, 7)
	spawn_at(left_col_start, 0, tile_size, $LeftColumnStart, 0)
	
	init_play_timer()


func play() -> void:
	
	current_events = data._get_events(current_beat)
	
	if current_events.is_empty():
		return
	
	var event_position : Vector2
	
	for event in current_events:
		
		event_position = Vector2(event.x, event.y)
		# search for the index the event position is inside of local_positions and spawn it there
		
	
	current_beat += 1


func init_play_timer() -> void:
	beat_length = (60 / bpm)
	total_beats = song_length / beat_length
	$PlayTimer.wait_time = beat_length


func spawn_at(start_pos : Vector2, x_add : int, y_add : int, control_node : Control, constant : int) -> void:
	
	for i in rows:
		
		var spawn_pos : Vector2 = Vector2((x_add * i), (y_add * i)) + control_node.position
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
	$PlayTimer.start
