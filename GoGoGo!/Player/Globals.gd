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

#region signals
@warning_ignore("unused_signal")
signal player_sfx

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

@warning_ignore("unused_signal")
signal change_bpm

@warning_ignore("unused_signal")
signal get_new_bpm
#endregion
