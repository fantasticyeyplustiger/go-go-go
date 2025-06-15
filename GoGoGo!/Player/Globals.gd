extends Node

enum directions {DOWN, LEFT, RIGHT, UP}
		
enum obstacle_types {BOULDER, ROCK_PELLET, STEEL_BALL, IRON_PELLET, LASER}

const roll_direction = {directions.DOWN : Vector2i.DOWN, directions.LEFT : Vector2i.LEFT,
		directions.RIGHT : Vector2i.RIGHT, directions.UP : Vector2i.UP}

const obstacle_speed = {obstacle_types.BOULDER : 750, obstacle_types.ROCK_PELLET : 2000,
				obstacle_types.STEEL_BALL : 1500, obstacle_types.IRON_PELLET : 3000}

var data_path : String
var current_beat : int

# Globals.emit_signal(signal name) FOR EMITTING SIGNAL
# Globals.(signal name).connect() FOR CONNECTING SIGNAL TO A FUNCTION

#region signals
@warning_ignore_start("unused_signal")
signal player_sfx
signal instruct
signal equalizer_height
signal gradient_brightness
signal gradient_pulse
signal bg_pulse
signal change_bpm
signal get_new_bpm
signal stopped_pausing
signal update_no_boulder_sfx
signal update_no_player_sfx
#endregion

var master_volume_percent : int = 100
var music_volume_percent : int = 50
var sfx_volume_percent : int = 50
var no_boulder_sfx : bool = false
var no_player_sfx : bool = false

# for the record this is coded terribly and i know it is im just too lazy to make it better
func _ready() -> void:
	connect("update_no_boulder_sfx", update_no_boulder_sfx_variable)
	connect("update_no_player_sfx", update_no_player_sfx_variable)

func update_no_boulder_sfx_variable(new_value : bool) -> void:
	no_boulder_sfx = new_value

func update_no_player_sfx_variable(new_value : bool) -> void:
	no_player_sfx = new_value

func load_settings() -> void:
	var save_file = FileAccess.open("res://SettingsData.txt", FileAccess.READ)
	var data = JSON.parse_string(save_file.get_line)
	
	master_volume_percent = data.master_volume_percent
	music_volume_percent = data.music_volume_percent
	sfx_volume_percent = data.sfx_volume_percent
	no_boulder_sfx = data.no_boulder_sfx
	no_player_sfx = data.no_player_sfx

func save_settings() -> void:
	var json = {
		"master_volume_percent" : master_volume_percent,
		"music_volume_percent" : music_volume_percent,
		"sfx_volume_percent" : sfx_volume_percent,
		"no_boulder_sfx" : no_boulder_sfx,
		"no_player_sfx" : no_player_sfx
	}
	
	var save_file = FileAccess.open("res://SettingsData.txt", FileAccess.WRITE)
	save_file.store_string( JSON.stringify(json) )
