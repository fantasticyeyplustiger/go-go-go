extends Control

const editor_path : String = "res://LevelEditor/LevelEditor.tscn"
const test_level : String = "res://Levels/testing_level.tscn"
var is_playing_loaded_level : bool = false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	Globals.data_path = ""
	Globals.beat_to_play_on = 0


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


func go_to_other() -> void:
	$AnimationPlayer.play("move_right_right")


func other_to_main_menu() -> void:
	$AnimationPlayer.play("other_to_menu")


func quit() -> void:
	get_tree().quit(0)


func load_level(path : String) -> void:
	
	if not OS.get_name() == "Linux" or not OS.get_name() == "X11":
		if not path.get_extension() == "ggg":
			$LoadFilePopup.visible = true
			await get_tree().create_timer(2.5).timeout
			$LoadFilePopup.visible = false
			return
	
	Globals.data_path = path
	
	if is_playing_loaded_level:
		get_tree().change_scene_to_file(test_level)
	else:
		enter_level_editor()

func open_import_level() -> void:
	$LevelImport.popup()

func open_import_song() -> void:
	$SongImport.popup()

func open_load_level() -> void:
	$LoadLevel.popup()

func import_level(path : String) -> void:
	
	if not OS.get_name() == "Linux" or not OS.get_name() == "X11":
		if not path.get_extension() == "ggg":
			popup("The level must be a .ggg file!")
			return
	
	var user_dir = DirAccess.open("user://")
	
	if not path.get_base_dir() == "user://":
		
		# If a level with the same name already exists in user data, loop until there isn't.
		var new_path : String
		var adding_string : int = 0
		
		if FileAccess.file_exists("user://" + path.get_file()):
			while true:
				if FileAccess.file_exists("user://" + str(adding_string) + path.get_file()):
					adding_string += 1
				else:
					new_path = "user://" + str(adding_string) + path.get_file()
					break
		else:
			new_path = path.get_file()
		
		if OS.get_name() == "Linux" or OS.get_name() == "X11":
			new_path = new_path.get_basename()
		
		var _new_file = FileAccess.open(new_path, FileAccess.WRITE)
		
		user_dir.copy(path, new_path)

func import_song(path : String) -> void:
	
	var extension : String = path.get_extension()
	
	if extension == "ogg":
		
		var directory = DirAccess.open("user://")
		directory.make_dir("Music") # in case it doesn't already exist
		
		var _new_file = FileAccess.open("user://Music/" + path.get_file(), FileAccess.WRITE)
		directory.copy(path, "user://Music/" + path.get_file())
		
		popup("Successfully imported song!")
	else:
		popup("Must be a .ogg audio file!")

func load_level_and_play() -> void:
	is_playing_loaded_level = true
	open_load_level()

func load_level_and_edit() -> void:
	is_playing_loaded_level = false
	open_load_level()

func popup(text : String) -> void:
	$LevelLoading/VBoxContainer/Popup.text = text
	await get_tree().create_timer(3.0).timeout
	$LevelLoading/VBoxContainer/Popup.text = ""
