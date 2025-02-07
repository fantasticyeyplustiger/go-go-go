extends Node

class_name RandomLevel

var event_timings = []
var events = []

var rows : int
var columns : int

func initialize(new_rows : int, new_columns : int, new_events) -> void:
	rows = new_rows
	columns = new_columns
	
	
	var temp_event_timings = []
	
	for event in new_events:
		temp_event_timings.append(event.timing)
	
	temp_event_timings.sort()
	
	var index : int = 1
	
	# Removes all duplicates found in temp_event_timings and adds the sorted elements to event_timings
	while index < temp_event_timings.size():
		
		if not temp_event_timings[index] == temp_event_timings[index - 1]:
			event_timings.append(temp_event_timings[index - 1])
		
		index += 1

func create_random_events():
	# for every beat there is an event, choose a number from 1-6 obstacles
	# randomize locations of each obstacle. each obstacle must be in a different location.
	
	
	
	for timing in event_timings:
		
		var obstacle_count : int = randi_range(1, 4)
		var obstacle_index : int = 0
		
		var type : int = randi_range(0, 4)
		
		while obstacle_index < obstacle_count:
			
			var direction : int = randi_range(0, 3)
			var position : Vector2i
			
			var position_row : int = randi_range(1, rows)
			var position_col : int = randi_range(1, columns)
			
			match direction:
				0: # DOWN
					position = Vector2i(position_row, columns + 1)
				1: # LEFT
					position = Vector2i(0, position_col)
				2: # RIGHT
					position = Vector2i(rows + 1, position_col)
				3: # UP
					position = Vector2i(position_row, 0)
			
			if check_for_event(timing, position):
				continue
			
			events.append(create_event(timing, type, position))
			obstacle_index += 1


'''
Creates and returns an event (dictionary) with the given parameters.
'''
func create_event(timing : int, type : int, position : Vector2i):
	return {
		"timing" : timing,
		"type" : type,
		"x" : position.x, # JSONs can't parse Vectors, so position is separated into x and y
		"y" : position.y
	}

func check_for_event(timing : int, position : Vector2i) -> bool:
	
	for event in events:
		
		if event.timing == timing:
			if event.x == position.x and event.y == position.y:
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
