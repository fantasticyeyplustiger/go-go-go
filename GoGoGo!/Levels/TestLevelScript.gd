extends Node2D

#region properties
@export var rows : int = 0
@export var columns : int = 0

@onready var obstacle_holder : Node = $ObstacleHolder
@onready var music = $Equalizer/Music
@onready var pulse = preload("res://GUI/Pulse.tscn")

const level_editor : String = "res://LevelEditor/LevelEditor.tscn"
const main_menu : String = "res://GUI/MainMenu.tscn"
const left_pulse_pos : Vector2 = Vector2(-296, -2000)
const right_pulse_pos : Vector2 = Vector2(1784, -2000)
const tile_size : int = 256

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
var current_beat : int = 0
var arrow_beats : int
var bpm : float

var data = LevelData.new()
var debug_vector : Vector2i = Vector2i(-1, -1)

var first_wave : bool = true
var start : bool = false
var obstacle_is_laser = false

# Obstacles
var boulder = preload("res://Obstacles/Boulder.tscn")
var pellet = preload("res://Obstacles/RockPellet.tscn")
var steel_ball = preload("res://Obstacles/SteelBall.tscn")
var iron_pellet = preload("res://Obstacles/IronPellet.tscn")
var laser = preload("res://Obstacles/LaserBeam.tscn")

# Arrows
var boulder_arrow = preload("res://Arrows/boulder_arrow.tscn")
var rock_pellet_arrow = preload("res://Arrows/rock_pellet_arrow.tscn")
var steel_ball_arrow = preload("res://Arrows/steel_ball_arrow.tscn")
var iron_pellet_arrow = preload("res://Arrows/iron_pellet_arrow.tscn")
var laser_arrow = preload("res://Arrows/laser_arrow.tscn")

var random_level = RandomLevel.new()
var use_random : bool = false
var paused : bool = false

var wait_for_arrows : int = -4 # Not sure why it has to be -4 instead of -5, but it works
#endregion


'''
Initializes important data and loads the level.
- Called before everything else.
'''
func _ready() -> void:
	
	$AttemptCount.text = "Attempt " + str(Globals.attempt_count)
	
	Globals.player_sfx.connect(player_sfx)
	get_window().focus_exited.connect(pause)
	
	if Globals.data_path.is_empty():
		data._load("res://MainLevels/Filibuster")
	else:
		data._load(Globals.data_path)
		
		if not data.song_path.is_empty():
			if data.song_path.begins_with("res://"):
				music.stream = load(data.song_path)
			else:
				music.stream = AudioStreamOggVorbis.load_from_file(data.song_path)
		
		bpm = data.bpm
	
	if data.random_attacks:
		random_level.initialize(rows, columns, data.events)
		random_level.create_random_events()
		use_random = true
	
	arrow_beats = Globals.beat_to_play_on - 5 # So they start earlier than the actual obstacles.
	current_beat = Globals.beat_to_play_on
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
	
	$LeftGradient/AnimationPlayer.speed_scale = 1 / (beat_length * 2)
	$RightGradient/AnimationPlayer.speed_scale = 1 / (beat_length * 2)

func player_sfx():
	$PlayerSFX.pitch_scale = randf_range(1.5, 3)
	$PlayerSFX.play()

'''
Shows the arrows for every obstacle that exists from the third beat after current_beat.
Places down every obstacle that exists for this beat from the events in data.
- Called once every "beat" (from $PlayTimer).
'''
func play() -> void:
	
	# In case player decides to change these settings mid-game.
	if not Globals.setting_player_sfx:
		$PlayerSFX.volume_linear = 0
	if not Globals.boulder_sfx:
		$SFX.volume_linear = 0
	
	if current_beat > data.last_beat:
		$PlayTimer.stop()
		await get_tree().create_timer(3.0).timeout
		$EndLabel.visible = true
		$EndColorRect.visible = true
		# Show win screen.
	
	show_arrows()
	
	if wait_for_arrows < 0:
		wait_for_arrows += 1
		return
	
	if first_wave:
		music.play(beat_length * current_beat)
		first_wave = false
	
	if use_random:
		current_events = random_level._get_events(current_beat)
	else:
		current_events = data._get_events(current_beat)
	
	bg_events()
	
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
			obstacle.direction = Globals.directions.RIGHT
		
		else: #elif event.x == rows + 1 and event.y > 0:, base direction is always LEFT
			obstacle.direction = Globals.directions.LEFT
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
Handles any changes in the background from the level's data.
'''
func bg_events():
	if data.check_for_timing_at(current_beat, data.equalizer_heights):
		var new_height = data.get_element_at(current_beat, data.equalizer_heights)
		$Equalizer.set_height(new_height.value)
	
	if data.check_for_timing_at(current_beat, data.gradient_brightnesses):
		var brightness = data.get_element_at(current_beat, data.gradient_brightnesses)
		
		var new_brightness = $LeftGradient.modulate
		new_brightness.a8 = brightness.value
		
		var g_tween = get_tree().create_tween()
		var g_tween2 = get_tree().create_tween()
		
		g_tween.tween_property($LeftGradient, "modulate", new_brightness, beat_length)
		g_tween2.tween_property($RightGradient, "modulate", new_brightness, beat_length)
	
	if data.check_for_element_at(current_beat, data.gradient_pulse_times):
		$LeftGradient.pulse()
		$RightGradient.pulse()
	
	if data.check_for_element_at(current_beat, data.bg_pulses):
		add_bg_pulse(left_pulse_pos, true)
		add_bg_pulse(right_pulse_pos, false)

func add_bg_pulse(target_position : Vector2, is_left : bool) -> void:
	var new_pulse = pulse.instantiate()
	new_pulse.set_anim_speed( 1 / (beat_length * 2) )
	
	if is_left:
		new_pulse.pulse_left()
	else:
		new_pulse.pulse_right()
	
	new_pulse.position = target_position
	add_child(new_pulse)

'''
Shows the locations of where the next obstacles will appear after x beats.
- Called from play().
- Calls get_spawn_position() and set_arrow(), an Arrow method.
'''
func show_arrows() -> void:
	
	# Condition is + 5 so it doesn't go out of the events' bounds.
	if arrow_beats + 5 < data.last_beat:
		
		if use_random:
			current_events = random_level._get_events(arrow_beats + 5)
		else:
			current_events = data._get_events(arrow_beats + 5)
		
		arrow_beats += 1
	
	else:
		return
	
	# If it's empty, there is no need to run this code.
	if current_events.is_empty():
		return
	
	var event_position : Vector2i
	var spawn_position : Vector2i
	
	for event in current_events:
		
		var new_arrow
		
		match int(event.type):
			Globals.obstacle_types.BOULDER, 0 : new_arrow = boulder_arrow.instantiate()
			Globals.obstacle_types.ROCK_PELLET, 1 : new_arrow = rock_pellet_arrow.instantiate()
			Globals.obstacle_types.STEEL_BALL, 2 : new_arrow = steel_ball_arrow.instantiate()
			Globals.obstacle_types.IRON_PELLET, 3 : new_arrow = iron_pellet_arrow.instantiate()
			Globals.obstacle_types.LASER, 4 : new_arrow = laser_arrow.instantiate()
			_: new_arrow = boulder_arrow.instantiate()
		
		event_position = Vector2i(event.x, event.y)
		spawn_position = get_spawn_position(event_position)
		
		#region Decides the arrow's pointing direction.
		if event.x > 0 and event.y == 0:
			new_arrow.set_arrow(Globals.directions.DOWN)
		
		elif event.x == 0 and event.y > 0:
			new_arrow.set_arrow(Globals.directions.RIGHT)
		
		elif event.x == rows + 1 and event.y > 0:
			new_arrow.set_arrow(Globals.directions.LEFT)
		
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
	Globals.attempt_count += 1

'''
Respawns the player when they press the letter "R."
Pauses game if player presses "ESC."
'''
func _unhandled_input(_event):
	if Input.is_action_pressed("respawn"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("pause"):
		paused = not paused
		
		if paused: pause()
		else: $PauseMenuCanvas/PauseMenu.resume()

'''
Pauses the game and opens the pause menu.
'''
func pause() -> void:
	get_tree().paused = true
	$PauseMenuCanvas/PauseMenu.visible = true
