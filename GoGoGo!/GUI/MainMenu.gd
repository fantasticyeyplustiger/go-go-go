extends Control

var editor_path : String = "res://LevelEditor/LevelEditor.tscn"


func _ready() -> void:
	$AnimationPlayer.play("RESET")


func enter_level_editor() -> void:
	get_tree().change_scene_to_file(editor_path)


# The animation player will move the GUI accordingly.

func open_levels() -> void:
	$AnimationPlayer.play("move_left")


func open_settings() -> void:
	$AnimationPlayer.play("move_down")


func move_to_main_menu() -> void:
	$AnimationPlayer.play("move_right")


func move_up_to_main_menu() -> void:
	$AnimationPlayer.play("move_up")


func quit() -> void:
	get_tree().quit(0)


func load_level() -> void:
	pass # Replace with function body.
