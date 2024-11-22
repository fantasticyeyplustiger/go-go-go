extends Node

var songMilliseconds=0

enum directions {DOWN, LEFT, RIGHT, UP}
		
enum obstacle_types {BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET}

const roll_direction = {directions.DOWN : Vector2.DOWN, directions.LEFT : Vector2.LEFT,
		directions.RIGHT : Vector2.RIGHT, directions.UP : Vector2.UP}

const obstacle_speed = {obstacle_types.BOULDER : 750, obstacle_types.ROCK_PELLET : 2000,
				obstacle_types.STEEL_BALL : 2000, obstacle_types.IRON_PELLET : 3000}

# Globals.emit_signal(signal name)
# Globals.(signal name).connect()

signal roll_obstacle(roll_velocity)
signal stop_level()
signal instruct

class levelData: 
	var events = []
	var json = JSON.new
	var path = "user://data.json"
	
	func _create_event(timing : int, type : int, position : Vector2):
		return {
			"timing" : timing * 1000,
			"type" : type,
			"activated" : false,
			"position" : position
		}
	
	func _add_event(timing : int, type : int, position : Vector2) -> void:
		events.append(_create_event(timing, type, position))
	
	
	func _remove_event(timing : int, type : int, position : Vector2) -> void:
		
		var data_struct = _create_event(timing, type, position)
		
		var iterator : int = 0
		
		for data in events:
			if data_struct == data:
				events.remove_at(iterator)
				return
			
			iterator += 1
	
	
	func _check_event_exists(timing : int, type : int, position : Vector2) -> bool:
		var data_struct = _create_event(timing, type, position)
		
		for data in events:
			if data_struct == data:
				return true
		
		return false
	
	
	
	
	
	func _get_events(timing : int):
		var returning_events = []
		timing *= 1000
		# timing is multiplied 1000 to convert it into milliseconds, just like data_struct
		
		for data in events:
			
			if data.timing == timing:
				returning_events.append(data)
		
		return returning_events
	
	
	func _get_event_positions(timing : int, type : int):
		var returning_events : Array[Vector2] = []
		timing *= 1000
		# timing is multiplied 1000 to convert it into milliseconds, just like data_struct
		
		for data in events:
			
			if data.timing == timing and data.type == type:
				returning_events.append(data.position)
		
		return returning_events
	
	
	func _load_from_string(string):
		var data = JSON.parse_string(string)
		events = data.events
	
	
	func _stringify():
		var saved_data={
			"events" : events
		}
		return JSON.stringify(saved_data)
	
	
	func save(content : String):
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(json.stringify(content))
		file.close()
		file = null
	
	
