extends Node

class_name RandomLevel

var event_timings = []
var events

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
	
	while index < temp_event_timings.size():
		
		if not temp_event_timings[index] == temp_event_timings[index - 1]:
			event_timings.append(temp_event_timings[index - 1])
		
		index += 1
	
	print(temp_event_timings)
	print(event_timings)

func create_random_events():
	# for every beat there is an event, choose a number from 1-6 obstacles
	# randomize locations of each obstacle. each obstacle must be in a different location.
	
	for timing in event_timings:
		var obstacle_count = randi_range(1, 6)
		
		for count in obstacle_count:
			
			var direction : int = randi_range(0, 3)
			var position : Vector2i
			
			var position_row : int = randi_range(1, rows)
			var position_col : int = randi_range(1, columns)
			
			match direction:
				0: # DOWN
					position = Vector2i(position_row, 7)
				1: # LEFT
					pass
				2: # RIGHT
					pass
				3: # UP
					pass
			
			var type : int = randi_range(0, 4)
			
			events.append(create_event(timing, type, position))


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
