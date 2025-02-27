extends Button

@export var level_id : int

var main_levels = MainLevels.new()
var level : String

func go_to_level() -> void:
	level = main_levels.levels[level_id - 1]
	Globals.data_path = level
	get_tree().change_scene_to_file("res://Levels/testing_level.tscn")
