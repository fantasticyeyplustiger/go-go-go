extends Control

const level_editor_path : String = "res://LevelEditor/LevelEditor.tscn"
const main_menu_path : String = "res://GUI/MainMenu.tscn"

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
	get_tree().paused = false
	Globals.attempt_count = 1
