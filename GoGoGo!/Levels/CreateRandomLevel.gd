extends Node

class_name RandomLevel

var data_events
var random_events

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
