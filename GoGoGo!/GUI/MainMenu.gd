extends Control

func enter_level_editor() -> void:
	pass # Replace with function body.


func open_levels() -> void:
	$AnimationPlayer.play("move_left")


func open_settings() -> void:
	$AnimationPlayer.play("move_down")


func move_to_main_menu() -> void:
	$AnimationPlayer.play("move_right")


func move_up_to_main_menu() -> void:
	$AnimationPlayer.play("move_up")
