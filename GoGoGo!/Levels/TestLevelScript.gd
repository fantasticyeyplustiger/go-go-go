extends Node2D

@export var rows : int = 0
@export var columns : int = 0

@onready var obstacle_holder : Node = $ObstacleHolder
@onready var music = $Control/Music

const level_editor : String = "res://LevelEditor/LevelEditor.tscn"

var tile_size = 256

var down_row_start : Vector2i
var up_row_start : Vector2i
var right_col_start : Vector2i
var left_col_start : Vector2i

var spawn_positions : Array[Vector2i] = []
var local_positions : Array[Vector2i] = []
var current_events : Array

var next_beat : float = 0
var beat_length : float
var song_length : float
var total_beats : int
var current_beat : int = -4
var bpm : float

var data = Globals.levelData.new()
var debug_vector : Vector2i = Vector2i(-1, -1)

var first_wave : bool = true
var start : bool = false
var obstacle_is_laser = false

var boulder = preload("res://Obstacles/Boulder.tscn")
var pellet = preload("res://Obstacles/RockPellet.tscn")
var steel_ball = preload("res://Obstacles/SteelBall.tscn")
var iron_pellet = preload("res://Obstacles/IronPellet.tscn")
var laser = preload("res://Obstacles/LaserBeam.tscn")

var arrow = preload("res://Arrows/boulder_arrow.tscn")
var laser_arrow = preload("res://Arrows/laser_arrow.tscn")


'''
Initializes important data and loads the level.
- Called before everything else.
'''
func _ready() -> void:
	
	if Globals.data_path.is_empty():
		data._load("res://SavedLevels/filibuster")
	else:
		data._load(Globals.data_path)
		
		if not data.song_path.is_empty():
			music.stream = load(data.song_path)
		
		bpm = data.bpm
	
	song_length = music.stream.get_length()
	
	#region Initializes spawn_positions and local_positions.
	down_row_start = $DownRowStart.position
	up_row_start = $UpRowStart.position
	right_col_start = $RightColumnStart.position
	left_col_start = $LeftColumnStart.position
	
	spawn_at(down_row_start, tile_size, 0, rows + 1)
	spawn_at(up_row_start, tile_size, 0, 0)
	spawn_at(right_col_start, 0, tile_size, 0)
	spawn_at(left_col_start, 0, tile_size, columns + 1)
	#endregion
	
	init_play_timer()


'''
Shows the arrows for every obstacle that exists from the third beat after current_beat.
Places down every obstacle that exists for this beat from the events in data.
- Called once every "beat" (from $PlayTimer).
'''
func play() -> void:
	
	if current_beat > data.last_beat:
		$PlayTimer.stop()
		# Show win screen.
	
	show_arrows()
	
	if current_beat < 0:
		current_beat += 1
		return
	
	if first_wave:
		music.play()
		first_wave = false
	
	current_events = data._get_events(current_beat)
	$WaveLabel.text = "Beat: " + str(current_beat) # Debugging.
	
	# If it's empty, there is no need to run this code.
	if current_events.is_empty():
		current_beat += 1
		return
	
	var event_position : Vector2i
	var spawn_position : Vector2i
	var obstacle
	
	# Places all of the obstacles from the current beat.
	for event in current_events:
		
		obstacle = get_obstacle(event)
		self.add_child(obstacle)
		move_child(obstacle, 6)
		
		event_position = Vector2i(event.x, event.y)
		spawn_position = get_spawn_position(event_position)
		
		#region Decides obstacle's roll direction.
		# Decides by looking at its local_position on the grid.
		if event.x > 0 and event.y == 0:
			obstacle.direction = Globals.directions.DOWN
		
		elif event.x > 0 and event.y == columns + 1:
			obstacle.direction = Globals.directions.UP
		
		elif event.x == 0 and event.y > 0:
			obstacle.direction = Globals.directions.LEFT
		
		else: #elif event.x == rows + 1 and event.y > 0:, base direction is always RIGHT
			obstacle.direction = Globals.directions.RIGHT
		#endregion
		
		# Changes where it rolls with the new direction.
		if obstacle_is_laser:
			
			obstacle.set_timer(beat_length)
			obstacle.rotate_beam()
		
		else:
			obstacle.change_velocity(obstacle.direction)
			
			# Randomly changes the pitch to prevent "audio fatigue."
			$SFX.pitch_scale = randf_range(1.5, 4.5)
			$SFX.play()
		
		obstacle.global_position = spawn_position
		obstacle_is_laser = false
		event.activated = true
	
	
	current_beat += 1

'''
Shows the locations of where the next obstacles will appear after three beats.
- Called from play().
- Calls get_spawn_position() and set_arrow(), an Arrow method.
'''
func show_arrows() -> void:
	
	
	
	# Condition is + 3 so it doesn't go out of the events' bounds.
	if current_beat + 4 < data.last_beat:
		current_events = data._get_events(current_beat + 4)
	else:
		return
	
	# If it's empty, there is no need to run this code.
	if current_events.is_empty():
		return
	
	var event_position : Vector2i
	var spawn_position : Vector2i
	
	for event in current_events:
		
		var new_arrow
		# Change this to "get" a specific type of arrow eventually.
		if not event.type == Globals.obstacle_types.LASER:
			new_arrow = arrow.instantiate()
		else:
			new_arrow = laser_arrow.instantiate()
		
		event_position = Vector2i(event.x, event.y)
		spawn_position = get_spawn_position(event_position)
		
		#region Decides the arrow's pointing direction.
		if event.x > 0 and event.y == 0:
			new_arrow.set_arrow(Globals.directions.DOWN)
		
		elif event.x == 0 and event.y > 0:
			new_arrow.set_arrow(Globals.directions.LEFT)
		
		elif event.x == rows + 1 and event.y > 0:
			new_arrow.set_arrow(Globals.directions.RIGHT)
		
		# it's already pointing up
		# elif event.x > 0 and event.y == columns + 1:
			# obstacle.direction = Globals.directions.UP
		#endregion
		
		new_arrow.global_position = spawn_position
		
		$ArrowHolder.add_child(new_arrow)
		
		new_arrow.set_wait(beat_length * 4)


'''
Instantiates a specific type of obstacle from the data given.
- Called from play().
- Calls get_obstacle_type().
'''
func get_obstacle(event):
	
	var obstacle_type = get_obstacle_type(event.type)
	
	match obstacle_type:
		
		Globals.obstacle_types.BOULDER:
			var a_boulder = boulder.instantiate()
			return a_boulder
		
		# add return instantiated scene accordingly
		Globals.obstacle_types.ROCK_PELLET:
			var a_pellet = pellet.instantiate()
			return a_pellet
		
		Globals.obstacle_types.STEEL_BALL:
			var a_steel_ball = steel_ball.instantiate()
			return a_steel_ball
		
		Globals.obstacle_types.IRON_PELLET:
			var an_iron_pellet = iron_pellet.instantiate()
			return an_iron_pellet
		
		Globals.obstacle_types.LASER:
			var a_laser = laser.instantiate()
			obstacle_is_laser = true
			return a_laser

'''
Gets the type of obstacle from an int and converts it to the actual enum value.
- Called from get_obstacle().
'''
func get_obstacle_type(type) -> Globals.obstacle_types:
	for i in Globals.obstacle_types.keys().size():
		if type == i:
			var key : String = Globals.obstacle_types.find_key(i)
			return Globals.obstacle_types[key]
	
	return Globals.obstacle_types.BOULDER

'''
Uses local_position to find the spawn location's index in spawn_positions.
(The two are initialized at the same spots and indexes.)
- Called from show_arrows() and play().
'''
func get_spawn_position(local_position : Vector2i) -> Vector2i:
	var index = local_positions.find(local_position, 0)
	return spawn_positions[index]

'''
Initializes the length of $PlayTimer's wait time and declares total_beats.
- Called from _ready().
'''
func init_play_timer() -> void:
	
	bpm = data.bpm
	
	beat_length = (60 / bpm)
	
	@warning_ignore("narrowing_conversion")
	total_beats = song_length / beat_length
	
	$PlayTimer.wait_time = beat_length

'''
Initializes every spawn location and local position accordingly for a singular row or column.
- Called from _ready().
- Calls init_local_positions().
'''
func spawn_at(start_pos : Vector2i, x_add : int, y_add : int, constant : int) -> void:
	
	for i in rows:
		
		var spawn_pos : Vector2i = Vector2i((x_add * i), (y_add * i))
		spawn_pos += start_pos
		
		spawn_positions.append(spawn_pos)
	
	init_local_positions(x_add == 0, constant)
	

'''
Initializes a row or column of local positions after a row or column of spawn locations are initialized.
- Called from spawn_at().
'''
func init_local_positions(constant_is_x : bool, constant : int) -> void:
	if constant_is_x:
		for i in columns:
			local_positions.append(Vector2i(constant, i + 1))
	
	else:
		for i in rows:
			local_positions.append(Vector2i(i + 1, constant))

'''
- Starts the level after $StartLevel's timer goes off.
'''
func start_level() -> void:
	$PlayTimer.start()

'''
- Respawns the player when they press the letter "R."
'''
func _unhandled_input(_event):
	if Input.is_action_pressed("respawn"):
		get_tree().reload_current_scene()


func go_back() -> void:
	get_tree().change_scene_to_file(level_editor)
