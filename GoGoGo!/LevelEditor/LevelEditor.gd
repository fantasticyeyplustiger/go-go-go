extends Control

const on_or_off_button_path : String = "res://LevelEditor/OnOrOffButton.tscn"
const tile_size : int = 256

var test_level : String = "res://Levels/testing_level.tscn"

var starting_bpm : float = 180.0
var bpm : float = 180.0
var total_buttons : int
var data : LevelData = LevelData.new()
var copy_data : LevelData = LevelData.new()

var current_beat : int = 0
var old_beat : int
var is_playing : bool = false
var buttons : Array[Button]

var song_length : int

var beat_length : float
var total_beats : int

var old_last_beat : int = -1

var has_saved : bool = true
var is_loading : bool = false
var chart_initialized : bool = false

@export var rows : int = 6
@export var columns : int = 6

@onready var song : AudioStreamPlayer = $Song
@onready var chartList : ItemList = $ItemList

func _ready():
	
	if not Globals.data_path.is_empty():
		data._load(Globals.data_path)
		bpm = data.bpm
		
		if not data.song_path.is_empty():
			if data.song_path.begins_with("res://"):
				song.stream = load(data.song_path)
			else:
				song.stream = AudioStreamOggVorbis.load_from_file(data.song_path)
	
	@warning_ignore("narrowing_conversion")
	song_length = song.stream.get_length() # MUST BE INITIALIZED BEFORE THE CHART IS
	
	initialize_chart()
	change_chart(0)
	
	Globals.instruct.connect(set_attack)
	Globals.equalizer_height.connect(set_equalizer_height)
	
	Globals.gradient_brightness.connect(set_gradient_brightness)
	Globals.gradient_pulse.connect(set_gradient_pulse)
	
	Globals.bg_pulse.connect(set_bg_pulse)
	
	Globals.get_new_bpm.connect(turn_new_bpm_button_visible)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons(tile_size, 0, $DownRowStart)
	load_buttons(tile_size, 0, $UpRowStart)
	load_buttons(0, tile_size, $RightColumnStart)
	load_buttons(0, tile_size, $LeftColumnStart)
	
	if not Globals.data_path.is_empty():
		set_icons()
		chartList.set_item_icon(data.last_beat, $End.texture)
	

func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("copy"):
		copy_attacks()
	
	elif Input.is_action_just_pressed("paste"):
		paste_attacks()
	
	elif Input.is_action_just_pressed("save"):
		save()
	
	elif Input.is_action_just_pressed("duplicate"):
		duplicate_attacks()
	
	elif Input.is_action_just_pressed("up"):
		go_up_chart()
	
	elif Input.is_action_just_pressed("down"):
		go_down_chart()
	
	elif Input.is_action_just_pressed("play"):
		play()


func go_up_chart() -> void:
	if not current_beat <= 0:
		change_chart(current_beat - 1)
		$ItemList.select(current_beat, true)

func go_down_chart() -> void:
	if not current_beat >= $ItemList.item_count - 1:
		change_chart(current_beat + 1)
		$ItemList.select(current_beat, true)

'''
Initializes all of the buttons inside of the editor.
'''
func load_buttons(x : int, y : int, control_node : Control) -> void:
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		control_node.add_child(new_child)
		buttons.push_back(new_child)
		new_child.position = Vector2(x * i, y * i)
		
		@warning_ignore("integer_division")
		new_child.local_position = Vector2i(
			(roundi(new_child.global_position.x - $ButtonOrigin.position.x)) / tile_size,
			(roundi(new_child.global_position.y - $ButtonOrigin.position.y)) / tile_size)
		

#region set functions
'''
Sets an attack at the corresponding location or deactivates it.
Called by OnOrOffButton being pressed.
'''
func set_attack(local_position : Vector2i, attack : bool, type : Globals.obstacle_types):
	
	has_saved = false
	
	if attack:
		data._add_event(current_beat, type, local_position)
		chartList.set_item_icon(current_beat, $Boulder.texture)
	
	else:
		data._remove_event(current_beat, local_position)
		
		if check_all_buttons_off():
			chartList.set_item_icon(current_beat, $Empty.texture)


func set_equalizer_height(height : int):
	has_saved = false
	data.change_height(current_beat, height)
	

func set_equalizer_color(color : Color):
	has_saved = false
	data.change_equalizer_color(current_beat, color)
	

func set_gradient_brightness(brightness : int):
	has_saved = false
	data.change_brightness(current_beat, brightness)
	

func set_gradient_color(color : Color):
	has_saved = false
	data.change_gradient_color(current_beat, color)


func set_gradient_pulse(is_on : bool):
	has_saved = false
	if is_on:
		data.gradient_pulse_at(current_beat)
	else:
		data.remove_gradient_pulse_at(current_beat)


func set_bg_pulse(is_on : bool):
	has_saved = false
	if is_on:
		data.set_bg_pulse(current_beat)
	else:
		data.remove_bg_pulse(current_beat)

'''
Puts a boulder as the icon of every part charted inside chartList.
'''
func set_icons():
	for event in data.events:
		# If statement placed in case user charts on beat 200 and lowers BPM so that chart is no longer available.
		if not event.timing >= chartList.item_count:
			chartList.set_item_icon(event.timing, $Boulder.texture)
#endregion

func initialize_chart() -> void:
	
	while chartList.item_count > 0:
		chartList.remove_item(0)
	
	beat_length = (60 / bpm)
	
	@warning_ignore("narrowing_conversion")
	total_beats = song_length / beat_length
	
	var sprite : Sprite2D = $Empty
	
	for i in total_beats * 2:
		chartList.add_item(str(i), sprite.texture, true)


func check_all_buttons_off() -> bool:
	
	for button in buttons:
		if button.attack == true:
			return false
	
	return true

'''
Turns every button off and disables their boulder sprites.
'''
func reset_buttons_to_false() -> void:
	for button in buttons:
		button.switch_off()

'''
Turns $LeftGUI/NewBPM visible.
'''
func turn_new_bpm_button_visible(is_on : bool):
	$LeftGUI/NewBPM.visible = is_on
	$LeftGUI/NewBPM.text = str(bpm)

'''
Asks the player to save if they've made any changes; then, sends player to the main menu.
'''
func quit() -> void:
	if not has_saved:
		$SaveFolderSelect.popup()
	
	get_tree().change_scene_to_file("res://GUI/MainMenu.tscn")


func play() -> void:
	
	var song_position : float
	song_position = current_beat * beat_length
	
	is_playing = not is_playing
	
	match is_playing:
		false:
			$MarginContainer/Buttons/PlayButton.text = "PLAY"
			$PlayTimer.stop()
			$Song.stop()
		
		true:
			$MarginContainer/Buttons/PlayButton.text = "PAUSE"
			$PlayTimer.wait_time = beat_length
			$PlayTimer.start()
			$Song.play(song_position)
			
			chartList.select(current_beat, true)
			chartList.ensure_current_is_visible()

func restart_beat():
	var song_position : float
	song_position = current_beat * beat_length
	
	$PlayTimer.start()
	$Song.play(song_position)
	
	chartList.select(current_beat, true)
	chartList.ensure_current_is_visible()

'''
Grabs the part of the chart you've changed to, saves the one you were at,
and loads changed chart. Resets all buttons to false if the loaded chart is empty.
- Called whenever the player selects a different part of the chart. (chartList / $ItemList)
'''
func change_chart(index : int) -> void:
	
	current_beat = index
	
	if is_playing:
		restart_beat()
	
	var exists : bool = false
	var attacks : Array = []
	
	for i in total_buttons:
		exists = data._check_event_exists(current_beat, buttons[i].local_position)
		
		if exists:
			reset_buttons_to_false()
			attacks = data._get_events(index)
			break
	
	$MarginContainer/Buttons/SaveButton.disabled = false
	$MarginContainer/BottomGUI/Labels/BeatLabel.text = "Beat: " + str(current_beat)
	
	change_bg_chart()
	
	if attacks.size() == 0:
		reset_buttons_to_false()
		return
	
	for attack in attacks:
		var pos = Vector2i(attack.x, attack.y)
		set_button_at(pos, attack.type)
	

func change_bg_chart() -> void:
	if not data.equalizer_heights.is_empty():
		var new_height = data.find_in_between_at(current_beat, data.equalizer_heights, 1200, true)
		$LeftGUI/EqualizerButton.change_sprite(new_height.value)
	
	if not data.gradient_brightnesses.is_empty():
		var new_brightness = data.find_in_between_at(current_beat, data.gradient_brightnesses, 90, true)
		$LeftGUI/GradientButton.change_sprite(new_brightness.value)
	
	if not data.gradient_pulse_times.is_empty():
		var pulse_exists : bool = data.check_for_element_at(current_beat, data.gradient_pulse_times)
		if pulse_exists:
			$LeftGUI/GradientPulse.switch_on()
		else:
			$LeftGUI/GradientPulse.switch_off()
	
	if not data.bg_pulses.is_empty():
		var pulse_exists : bool = data.check_for_element_at(current_beat, data.bg_pulses)
		if pulse_exists:
			$LeftGUI/BgPulseButton.switch_on()
		else:
			$LeftGUI/BgPulseButton.switch_off()
	
	## Too lazy to work on this atm so just leaving it commented for now
	#if not data.bpm_changes.is_empty():
		#var bpm_change = data.find_in_between_at(current_beat, data.bpm_changes, bpm, true)
		#$LeftGUI/NewBPM.visible = true
		#$LeftGUI/NewBPM.text = str(bpm_change)


'''
Turns on a specific button with the position given.
'''
func set_button_at(pos : Vector2i, type):
	for button in buttons:
		if button.local_position == pos:
			button.switch_on(type)


func for_every_beat() -> void:
	
	current_beat += 1
	if current_beat >= total_beats:
		$PlayTimer.stop()
	
	chartList.select(current_beat, true)
	chartList.ensure_current_is_visible()
	change_chart(current_beat)
	

'''
Copies the attack from the part of the chart the player has selected.
'''
func copy_attacks() -> void:
	
	var exists : bool
	
	for i in total_buttons:
		
		exists = data._check_event_exists(current_beat, buttons[i].local_position)
		
		if exists:
			copy_data.events = data._get_events(current_beat)
			break
	
	if not exists:
		copy_data.events = []
	
	$MarginContainer/Buttons/PasteButton.disabled = false

func paste_attacks() -> void:
	
	reset_buttons_to_false()
	
	for event in copy_data.events:
		var pos : Vector2i = Vector2i(event.x, event.y)
		set_attack(pos, true, event.type)
		set_button_at(pos, event.type)

func duplicate_attacks() -> void:
	
	if current_beat + 1 > chartList.item_count:
		return
	
	copy_attacks()
	
	change_chart(current_beat + 1)
	$ItemList.select(current_beat, true)
	
	paste_attacks()

#region functions that open file selectors
func save() -> void:
	$SaveFolderSelect.popup()

func load_data() -> void:
	$LoadSaveSelect.popup()

func load_song_import() -> void:
	$SongImport.popup()
#endregion

'''
Loads a level. Doesn't actually check if the file is valid as of now.
Sets the chart according to the data inside of the file.
'''
func load_save_file(path: String) -> void:
	
	if not OS.get_name() == "Linux" or not OS.get_name() == "X11":
		if not path.get_extension() == "ggg":
			$LoadFilePopup.visible = true
			await get_tree().create_timer(2.5).timeout
			$LoadFilePopup.visible = false
			return
	
	data = LevelData.new()
	
	for i in chartList.item_count:
		chartList.set_item_icon(i, $Empty.texture)
	
	data._load(path)
	Globals.data_path = path
	
	bpm = data.bpm
	chartList.select(0, true)
	$MarginContainer/Buttons/SpinBox.value = bpm
	
	if not data.song_path == "":
		# Used because the base dir isn't actually saved as "user" but as the absolute path
		# Mainly for when a person gives another person a level from their user files
		# Also the reason why music can ONLY be in user://Music or res://Music
		if not data.song_path.get_base_dir() == "user://Music" and not data.song_path.get_base_dir() == "res://Music":
			data.song_path = "user://Music/" + data.song_path.get_file()
		
		select_song(data.song_path)
	
	reset_buttons_to_false()
	
	for event in data.events:
		chartList.set_item_icon(event.timing, $Boulder.texture)
	
	if not data.last_beat == -1:
		chartList.set_item_icon(data.last_beat - 1, $End.texture)
	
	change_bg_chart()
	change_chart(0)
	
	has_saved = true


func save_folder_selected(path: String) -> void:
	
	if data.last_beat == -1:
		data.last_beat = total_beats
	if data.song_path == "":
		data.song_path = "res://Music/SkyHigh.ogg"
	
	if path.get_extension() == "ggg":
		data.save(path)
	else:
		data.save(path + ".ggg")
	has_saved = true


func bpm_changed(value: float) -> void:
	has_saved = false
	bpm = value
	initialize_chart()
	# remove or add chart items
	
	set_icons()
	
	chartList.select(0, true)
	data.bpm = bpm

'''
Attempts to import a song into the editor. Only works with ogg files at the moment.
'''
func song_import(path : String) -> void:
	
	var extension : String = path.get_extension()
	
	if extension == "ogg":
		
		$Song.stream = AudioStreamOggVorbis.load_from_file(path)
		
		var directory = DirAccess.open("user://")
		directory.make_dir("Music") # in case it doesn't already exist
		
		@warning_ignore("unused_variable")
		var new_file = FileAccess.open("user://Music/" + path.get_file(), FileAccess.WRITE)
		directory.copy(path, "user://Music/" + path.get_file())
		
		data.song_path = "user://Music/" + path.get_file()
		has_saved = false # at the end so if extension is invalid it won't imply something changed


func play_test() -> void:
	if not has_saved:
		$SaveFolderSelect.popup()
		return
	
	Globals.beat_to_play_on = current_beat
	get_tree().change_scene_to_file(test_level)


func open_help_menu() -> void:
	$EditorHelp.visible = true


func select_song(path: String) -> void:
	var extension : String = path.get_extension()
	
	if extension == "ogg":
		$Song.stream = AudioStreamOggVorbis.load_from_file(path)
		data.song_path = path
		has_saved = false # at the end so if extension is invalid it won't imply something changed


func load_song_select() -> void:
	var directory = DirAccess.open("user://")
	directory.make_dir("Music") # in case it doesn't already exist
	$SongSelect.popup()


func ending() -> void:
	has_saved = false
	var temp_current_beat : int = current_beat
	
	data.last_beat = current_beat
	chartList.set_item_icon(current_beat, $End.texture)
	
	if not old_last_beat == -1:
		change_chart(old_last_beat)
		
		if check_all_buttons_off():
			chartList.set_item_icon(old_last_beat, $Empty.texture)
		else:
			chartList.set_item_icon(old_last_beat, $Boulder.texture)
		
		change_chart(temp_current_beat)
	
	old_last_beat = temp_current_beat
	data.last_beat = temp_current_beat


func set_random_level() -> void:
	data.random_attacks = not data.random_attacks
	has_saved = false
	
	match data.random_attacks:
		false:
			$MarginContainer2/VBoxContainer/SetRandomButton.text = "random\nlevel off"
		true:
			$MarginContainer2/VBoxContainer/SetRandomButton.text = "RANDOM\nLEVEL ON"


func new_bpm_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		data.set_bpm(current_beat, int(new_text))


func reset_everything() -> void:
	
	save()
	
	var directory = DirAccess.open("user://")
	directory.make_dir("ResetAutoSaves") # in case it doesn't exist for whatever reason
	
	var save_file_path = "user://ResetAutoSaves/"
	var reset_saves = DirAccess.open("user://ResetAutoSaves")
	
	if reset_saves.get_files().is_empty():
		save_file_path += "1"
	else:
		var iterator : int = 2
		
		# Basically just loops until it finds a valid name it can use without overwriting anything
		while true:
			if reset_saves.get_files().has(str(iterator) + ".ggg"):
				iterator += 1
			else:
				save_file_path += str(iterator)
				break
	
	save_folder_selected(save_file_path)
	
	Globals.data_path = ""
	get_tree().reload_current_scene()

'''
Attempts to import a level from user-chosen file.
Copies level file over to user folder. Only works if file is a .ggg file.
'''
func import_level(path : String) -> void:
	
	if not OS.get_name() == "Linux" or not OS.get_name() == "X11":
		if not path.get_extension() == "ggg":
			$LoadFilePopup.visible = true
			await get_tree().create_timer(2.5).timeout
			$LoadFilePopup.visible = false
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
		
		load_save_file(new_path)


func load_level_import() -> void:
	$LevelImport.popup()


func play_test_at_beat_zero() -> void:
	current_beat = 0
	play_test()
