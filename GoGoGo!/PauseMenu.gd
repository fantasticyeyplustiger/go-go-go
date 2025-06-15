extends Control

const level_editor_path : String = "res://LevelEditor/LevelEditor.tscn"
const main_menu_path : String = "res://GUI/MainMenu.tscn"

func restart() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func resume() -> void:
	Engine.time_scale = 1.0
	self.visible = false
	Globals.emit_signal("stopped_pausing")

func editor() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(level_editor_path)

func main_menu() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(main_menu_path)
