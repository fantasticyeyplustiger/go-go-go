extends Node

enum directions {DOWN, LEFT, RIGHT, UP}
		
enum obstacle_types {BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET, LASER}

const roll_direction = {directions.DOWN : Vector2i.DOWN, directions.LEFT : Vector2i.LEFT,
		directions.RIGHT : Vector2i.RIGHT, directions.UP : Vector2i.UP}

const obstacle_speed = {obstacle_types.BOULDER : 750, obstacle_types.ROCK_PELLET : 2000,
				obstacle_types.STEEL_BALL : 1500, obstacle_types.IRON_PELLET : 3000}

var data_path : String
var current_beat : int

# Globals.emit_signal(signal name)
# Globals.(signal name).connect()

@warning_ignore("unused_signal")
signal instruct

@warning_ignore("unused_signal")
signal equalizer_height

@warning_ignore("unused_signal")
signal gradient_brightness

@warning_ignore("unused_signal")
signal gradient_pulse

@warning_ignore("unused_signal")
signal bg_pulse

class levelData: 
	var events = []
	
	var equalizer_heights = []
	var equalizer_colors = []
	var gradient_brightnesses = []
	var gradient_pulse_times = []
	var gradient_colors = []
	var bg_pulses = []
	
	var random_attacks : bool
	var bpm : float
	var old_laser_length : int
	var last_beat : int = -1
	var song_path : String
	
	
	func create_change_event(current_beat : int, value : int, value_name : String):
		return {
			"timing" : current_beat,
			value_name : value
			}
	
	func create_color_event(current_beat : int, color : Color):
		return {
			"timing" : current_beat,
			"color" : color.hex
		}
	
	#region equalizer methods
	func change_height(current_beat : int, new_height : int) -> void:
		remove_height_change(current_beat)
		equalizer_heights.append(create_change_event(current_beat, new_height, "height"))
	
	func remove_height_change(current_beat : int) -> void:
		var iterator : int = 0
		for height in equalizer_heights:
			
			if height.timing == current_beat:
				equalizer_heights.remove_at(iterator)
				return
			
			iterator += 1
	
	func change_equalizer_color(current_beat : int, new_color : Color) -> void:
		equalizer_colors.append(create_color_event(current_beat, new_color))
		
	#endregion
	
	#region gradient methods
	func change_brightness(current_beat : int, new_brightness : int) -> void:
		remove_brightness_change(current_beat)
		gradient_brightnesses.append(create_change_event(current_beat, new_brightness, "brightness"))
	
	func remove_brightness_change(current_beat : int) -> void:
		var iterator : int = 0
		for brightness in gradient_brightnesses:
			
			if brightness.timing == current_beat:
				gradient_brightnesses.remove_at(iterator)
				return
			
			iterator += 1
	
	func change_gradient_color(current_beat : int, new_color : Color) -> void:
		gradient_colors.append(create_color_event(current_beat, new_color))
	
	func gradient_pulse_at(current_beat : int) -> void:
		gradient_pulse_times.append(current_beat)
	
	func remove_gradient_pulse_at(current_beat : int) -> void:
		var iterator : int = 0
		for i in gradient_pulse_times:
			if i == current_beat:
				gradient_pulse_times.remove_at(iterator)
			
			iterator += 1
	#endregion
	
	#region bg pulse methods
	func set_bg_pulse(current_beat : int, direction : directions) -> void:
		remove_bg_pulse(current_beat)
		bg_pulses.append(create_change_event(current_beat, direction, "direction"))
		pass
	
	func remove_bg_pulse(current_beat : int) -> void:
		var iterator : int = 0
		for pulse in bg_pulses:
			if pulse.timing == current_beat:
				bg_pulses.remove_at(iterator)
			
			iterator += 1
	#endregion
	
	#region event methods
	'''
	Creates and returns an event (dictionary) with the given parameters.
	'''
	func _create_event(timing : int, type : int, position : Vector2i):
		return {
			"timing" : timing,
			"type" : type,
			"x" : position.x, # JSONs can't parse Vectors, so position is separated into x and y
			"y" : position.y
		}
	
	
	'''
	Creates an event and adds it to the events array.
	If an event already exists at its spot, remove it.
	
	- Called by LevelEditor.
	- Calls _remove_event() and _create_event().
	'''
	func _add_event(timing : int, type : int, position : Vector2i) -> void:
		_remove_event(timing, position)
		events.append(_create_event(timing, type, position))
	
	
	'''
	Removes an event at the specified beat and position.
	
	- Called by LevelEditor.
	'''
	func _remove_event(timing : int, position : Vector2i) -> void:
		
		var iterator : int = 0
		
		for data in events:
			if position.x == data.x and position.y == data.y and timing == data.timing:
				events.remove_at(iterator)
				return
			
			iterator += 1
	
	
	'''
	Checks if theres any type of event that can be seen inside of the [events] array
	at the specified beat and position.
	Returns [true] if exists, [false] otherwise.
	
	- Called by LevelEditor.
	'''
	func _check_event_exists(timing : int, position : Vector2i) -> bool:
		
		for data in events:
			
			# only these three variables need to be checked
			if (position.x == data.x) and (position.y == data.y) and (timing == data.timing):
				return true
		
		return false
	
	
	'''
	Gets every event that happens on a certain beat and returns an array of those [events].
	Not to be confused with _get_event_positions(), which returns positions instead.
	
	- Called by LevelEditor.
	'''
	func _get_events(timing : int):
		var returning_events = []
		
		for data in events:
			
			if data.timing == timing:
				returning_events.append(data)
		
		return returning_events
	
	
	'''
	Gets every position of the events that happen on a certain beat.
	Returns a [Vector2i] array with those positions.
	
	- Called by LevelEditor.
	'''
	func _get_event_positions(timing : int):
		var returning_events : Array[Vector2i] = []
		
		for data in events:
			
			if data.timing == timing:
				var position : Vector2i = Vector2i(data.x, data.y)
				returning_events.append(position)
		
		return returning_events
	#endregion
	
	#region saving and loading
	'''
	Loads from the [save_file] path.
	
	- Called by LevelEditor.
	'''
	func _load(save_file : String):
		var file = FileAccess.open(save_file, FileAccess.READ)
		var data = JSON.parse_string(file.get_line())
		
		events = data.events
		
		random_attacks = data.random_attacks
		bpm = data.bpm
		last_beat = data.last_beat
		
		song_path = data.song_path
		
		file = null
	
	'''
	Gets all of the data in this object and returns it as a single-line JSON String.
	
	- Called by save().
	'''
	func _stringify() -> String:
		var saved_data = {
			"events" : events,
			"random_attacks" : random_attacks,
			"bpm" : bpm,
			"song_path" : song_path,
			"last_beat" : last_beat
		}
		return JSON.stringify(saved_data)
	
	'''
	Saves all of the data in this object into a file at the [save_file] path.
	
	- save_file: the location data should be saved in.
	- Called by LevelEditor.
	'''
	func save(save_file : String):
		var file = FileAccess.open(save_file, FileAccess.WRITE)
		file.store_string(_stringify())
		
		Globals.data_path = file.get_path()
		
		file = null
	#endregion
	
