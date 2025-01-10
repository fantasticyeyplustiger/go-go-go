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

class levelData: 
	var events = []
	var random_attacks : bool
	var bpm : float
	var old_laser_length : int
	var last_beat : int = -1
	var song_path : String
	
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
	
	
