extends Control

class_name PauseMenu

const level_editor_path : String = "res://LevelEditor/LevelEditor.tscn"
const main_menu_path : String = "res://GUI/MainMenu.tscn"

func _ready() -> void:
	get_window().focus_exited.connect(pause)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and self.visible:
		resume()
	elif Input.is_action_just_pressed("pause"):
		pause()

func pause() -> void:
	get_tree().paused = true
	self.visible = true

func restart() -> void:
	going_somewhere_else()
	get_tree().reload_current_scene()

func resume() -> void:
	get_tree().paused = false
	self.visible = false

func editor() -> void:
	going_somewhere_else()
	get_tree().change_scene_to_file(level_editor_path)

func main_menu() -> void:
	going_somewhere_else()
	get_tree().change_scene_to_file(main_menu_path)

func open_settings() -> void:
	$Settings.visible = true

func going_somewhere_else() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
