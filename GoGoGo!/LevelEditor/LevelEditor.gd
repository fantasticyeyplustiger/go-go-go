extends Control

const on_or_off_button_path : String = "res://LevelEditor/OnOrOffButton.tscn"
const tile_size : int = 256

var test_level : String = "res://Levels/testing_level.tscn"

var bpm : float = 180.0
var total_buttons : int
var data : Globals.levelData = Globals.levelData.new()
var copy_data : Globals.levelData = Globals.levelData.new()

var current_beat : int = 0
var old_beat : int
var is_playing : bool = false
var buttons : Array[Button]

var song_length : int
var song : AudioStreamPlayer
var beat_length : float
var total_beats : int

var old_last_beat : int = -1

var has_saved : bool = false
var is_loading : bool = false
var chart_initialized = false

@export var rows : int = 6
@export var columns : int = 6


func _ready():
	
	if not Globals.data_path.is_empty():
		data._load(Globals.data_path)
		bpm = data.bpm
		initialize_chart()
		change_chart(0)
		
		if not data.song_path.is_empty():
			$Song.stream = load(data.song_path)
	
	song = $Song
	@warning_ignore("narrowing_conversion")
	song_length = song.stream.get_length()
	
	$MarginContainer/Buttons/SpinBox.value = bpm
	
	Globals.instruct.connect(set_attack)
	Globals.equalizer_height.connect(set_equalizer_height)
	Globals.gradient_brightness.connect(set_gradient_brightness)
	Globals.gradient_pulse.connect(set_gradient_pulse)
	Globals.bg_pulse.connect(set_bg_pulse)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons(tile_size, 0, $DownRowStart)
	load_buttons(tile_size, 0, $UpRowStart)
	load_buttons(0, tile_size, $RightColumnStart)
	load_buttons(0, tile_size, $LeftColumnStart)
	
	if not Globals.data_path.is_empty():
		set_icons()

func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_pressed("copy"):
		copy_attacks()
	
	elif Input.is_action_pressed("paste"):
		paste_attacks()
	
	elif Input.is_action_pressed("save"):
		save()
	
	elif Input.is_action_pressed("duplicate"):
		duplicate_attacks()


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
		$ItemList.set_item_icon(current_beat, $Boulder.texture)
	
	else:
		data._remove_event(current_beat, local_position)
		
		if check_all_buttons_off():
			$ItemList.set_item_icon(current_beat, $Empty.texture)


func set_equalizer_height(height : int):
	data.change_height(current_beat, height)
	

func set_equalizer_color(color : Color):
	data.change_equalizer_color(current_beat, color)
	

func set_gradient_brightness(brightness : int):
	data.change_brightness(current_beat, brightness)
	

func set_gradient_color(color : Color):
	data.change_gradient_color(current_beat, color)

func set_gradient_pulse(is_on : bool):
	if is_on:
		data.gradient_pulse_at(current_beat)
	else:
		data.remove_gradient_pulse_at(current_beat)

func set_bg_pulse(is_on : bool, direction : Globals.directions):
	if is_on:
		data.set_bg_pulse(current_beat, direction)
	else:
		data.remove_bg_pulse(current_beat)


func set_icons():
	
	for event in data.events:
		
		$ItemList.set_item_icon(event.timing, $Boulder.texture)
#endregion

func initialize_chart() -> void:
	
	while $ItemList.item_count > 0:
		$ItemList.remove_item(0)
	
	beat_length = (60 / bpm)
	
	@warning_ignore("narrowing_conversion")
	total_beats = song_length / beat_length
	
	var sprite : Sprite2D = $Empty
	
	for i in total_beats:
		$ItemList.add_item(str(i), sprite.texture, true)


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


func quit() -> void:
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
			
			$ItemList.select(current_beat, true)
			$ItemList.ensure_current_is_visible()

func restart_beat():
	var song_position : float
	song_position = current_beat * beat_length
	
	$PlayTimer.start()
	$Song.play(song_position)
	
	$ItemList.select(current_beat, true)
	$ItemList.ensure_current_is_visible()

'''
Grabs the part of the chart you've changed to, saves the one you were at,
and loads changed chart. Resets all buttons to false if the loaded chart is empty.
- Called whenever the player selects a different part of the chart. ($ItemList)
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


'''
Turns on a specific button with the position given.
'''
func set_button_at(pos : Vector2i, type):
	for button in buttons:
		if button.local_position == pos:
			button.switch_on(type)


func for_every_beat() -> void:
	
	current_beat += 1
	if current_beat > total_beats:
		$PlayTimer.stop()
	
	$ItemList.select(current_beat, true)
	$ItemList.ensure_current_is_visible()
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
	
	$MarginContainer/Buttons/PasteButton.disabled = false

func paste_attacks() -> void:
	
	reset_buttons_to_false()
	
	for event in copy_data.events:
		var pos : Vector2i = Vector2i(event.x, event.y)
		set_attack(pos, true, event.type)
		set_button_at(pos, event.type)

func duplicate_attacks() -> void:
	
	if current_beat + 1 > $ItemList.item_count:
		return
	
	copy_attacks()
	
	change_chart(current_beat + 1)
	
	paste_attacks()
	
	pass

#region functions that open file selectors
func save() -> void:
	$SaveFolderSelect.popup()

func load_data() -> void:
	$LoadSaveSelect.popup()

func load_song_import() -> void:
	$SongImport.popup()
#endregion

func load_save_file(path: String) -> void:
	
	has_saved = true
	
	data = Globals.levelData.new()
	
	for i in $ItemList.item_count:
		$ItemList.set_item_icon(i, $Empty.texture)
	
	data._load(path)
	Globals.data_path = path
	
	bpm = data.bpm
	$MarginContainer/Buttons/SpinBox.value = bpm
	
	if not data.song_path == "":
		select_song(data.song_path)
	
	reset_buttons_to_false()
	
	for event in data.events:
		$ItemList.set_item_icon(event.timing, $Boulder.texture)
	
	if not data.last_beat == -1:
		$ItemList.set_item_icon(data.last_beat, $End.texture)
	
	change_bg_chart()


func save_folder_selected(path: String) -> void:
	
	if data.last_beat == -1:
		data.last_beat = total_beats
	
	data.save(path)
	has_saved = true


func bpm_changed(value: float) -> void:
	bpm = value
	initialize_chart()
	# remove or add chart items
	
	$ItemList.select(0, true)
	data.bpm = bpm


func song_import(path : String) -> void:
	
	var extension : String = path.get_extension()
	
	if extension == "ogg":
		
		$Song.stream = AudioStreamOggVorbis.load_from_file(path)
		
		var directory = DirAccess.open("res://Music/")
		
		directory.copy(path, "res://Music/" + path.get_file())
		
		data.song_path = "res://Music/" + path.get_file()


func play_test() -> void:
	if not has_saved:
		$SaveFolderSelect.popup()
		has_saved = true
	
	get_tree().change_scene_to_file(test_level)


func open_help_menu() -> void:
	$EditorHelp.visible = true


func select_song(path: String) -> void:
	var extension : String = path.get_extension()
	
	if extension == "ogg":
		$Song.stream = AudioStreamOggVorbis.load_from_file(path)
		print(path)
		data.song_path = path


func load_song_select() -> void:
	$SongSelect.popup()


func ending() -> void:
	
	var temp_current_beat : int = current_beat
	
	data.last_beat = current_beat
	$ItemList.set_item_icon(current_beat, $End.texture)
	
	if not old_last_beat == -1:
		change_chart(old_last_beat)
		
		if check_all_buttons_off():
			$ItemList.set_item_icon(old_last_beat, $Empty.texture)
		else:
			$ItemList.set_item_icon(old_last_beat, $Boulder.texture)
		
		change_chart(temp_current_beat)
	
	old_last_beat = temp_current_beat
	data.last_beat = temp_current_beat


func set_random_level() -> void:
	data.random_attacks = not data.random_attacks
	
	match data.random_attacks:
		false:
			$MarginContainer2/VBoxContainer/SetRandomButton.text = "random\nlevel off"
		true:
			$MarginContainer2/VBoxContainer/SetRandomButton.text = "RANDOM\nLEVEL ON"
