extends Control

var editor_path : String = "res://LevelEditor/LevelEditor.tscn"

func enter_level_editor() -> void:
	get_tree().change_scene_to_file(editor_path)


func open_levels() -> void:
	$AnimationPlayer.play("move_left")


func open_settings() -> void:
	$AnimationPlayer.play("move_down")


func move_to_main_menu() -> void:
	$AnimationPlayer.play("move_right")


func move_up_to_main_menu() -> void:
	$AnimationPlayer.play("move_up")
