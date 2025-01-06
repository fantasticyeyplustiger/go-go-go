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
	
	song = $Song
	@warning_ignore("narrowing_conversion")
	song_length = song.stream.get_length()
	
	$MarginContainer/Buttons/SpinBox.value = bpm
	
	Globals.instruct.connect(set_attack)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons(tile_size, 0, $DownRowStart)
	load_buttons(tile_size, 0, $UpRowStart)
	load_buttons(0, tile_size, $RightColumnStart)
	load_buttons(0, tile_size, $LeftColumnStart)
	
	if not Globals.data_path.is_empty():
		set_icons()

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
		new_child.local_position = Vector2(
			(roundi(new_child.global_position.x - $ButtonOrigin.position.x)) / tile_size,
			(roundi(new_child.global_position.y - $ButtonOrigin.position.y)) / tile_size)
		


'''
Sets an attack at the corresponding location or deactivates it.
Called by OnOrOffButton being pressed.
'''
func set_attack(local_position : Vector2, attack : bool, type : Globals.obstacle_types):
	
	has_saved = false
	
	if attack:
		data._add_event(current_beat, type, local_position)
		$ItemList.set_item_icon(current_beat, $Boulder.texture)
	
	else:
		data._remove_event(current_beat, local_position)
		
		if check_all_buttons_off():
			$ItemList.set_item_icon(current_beat, $Empty.texture)


func set_icons():
	
	for event in data.events:
		
		$ItemList.set_item_icon(event.timing, $Boulder.texture)


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
	get_tree().quit()


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
			attacks = data._get_events(current_beat)
			break
	
	$MarginContainer/Buttons/SaveButton.disabled = false
	$MarginContainer/BottomGUI/Labels/BeatLabel.text = "Beat: " + str(current_beat)
	
	if attacks.size() == 0:
		reset_buttons_to_false()
		return
	
	for attack in attacks:
		var pos = Vector2(attack.x, attack.y)
		set_button_at(pos, attack.type)
	

'''
Turns on a specific button with the position given.
'''
func set_button_at(pos : Vector2, type):
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
Copies the attack from this part of the chart
'''
func copy_attacks() -> void:
	
	var exists : bool
	
	for i in total_buttons:
		
		exists = data._check_event_exists(current_beat, buttons[i].local_position)
		
		if exists:
			copy_data = data._get_events(current_beat)
			break
	
	$MarginContainer/Buttons/PasteButton.disabled = false

func paste_attacks() -> void:
	
	reset_buttons_to_false()
	
	for event in copy_data.events:
		var pos : Vector2 = Vector2(event.x, event.y)
		set_attack(pos, true, event.type)
		set_button_at(pos, event.type)

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
	reset_buttons_to_false()
	
	for event in data.events:
		$ItemList.set_item_icon(event.timing, $Boulder.texture)


func save_folder_selected(path: String) -> void:
	data.save(path, false)
	has_saved = true


func bpm_changed(value: float) -> void:
	bpm = value
	initialize_chart()
	# remove or add chart items
	
	$ItemList.select(0, true)
	data.bpm = bpm


func song_import(path : String) -> void:
	
	var extension : String = path.get_extension()
	
	if extension == "ogg" or extension == "mp3" or extension == "wav" and ResourceLoader.exists(path):
		
		import_file(path, extension)
		
		$Song.stream = load(path)
		data.song_path = path
	
	

func import_file(path : String, extension : String) -> void:
	
	var new_path = path + ".import"
	
	var import = FileAccess.open(new_path, FileAccess.WRITE)
	var source_file : String = "res://Music/" + path.get_file()
	var audio_extension : String
	var id : int = ResourceUID.create_id()
	var import_path : String = "res://.godot/imported/" + path.get_file()
	var path_two : String = "path=\"res://.godot/imported/" + path.get_file() + "-00000000000000000000000000000000"
	
	import_path += str( ResourceUID.id_to_text(id) ) + "." + extension + "str"
	path_two += extension + "str"
	
	ResourceUID.add_id(id, source_file)
	
	print(new_path)
	print(source_file)
	print(id)
	print(ResourceUID.id_to_text(id))
	print(import_path)
	print(path_two)
	
	import.store_line("[remap]\n")
	import.store_line("importer=\"" + extension + "\"")
	
	match extension:
		
		"ogg":
			audio_extension = "OggVorbis"
		"mp3":
			audio_extension = "MP3"
		"wav":
			audio_extension = "WAV"
		
	import.store_line("type=\"AudioStream" + audio_extension + "\"")
	import.store_line(ResourceUID.id_to_text(id))
	import.store_line(path_two)
	
	import.store_line("\n[deps]\n")
	import.store_line("source_file=\"" + source_file + "\"")
	import.store_line("dest_files=[\"" + path_two + "]\n")
	
	import.store_line("[params]\n")
	import.store_line("loop=false")
	import.store_line("loop_offset=0")
	import.store_line("bpm=0")
	import.store_line("beat_count=0")
	import.store_line("bar_beats=4")
	
	import = null

func play_test() -> void:
	if not has_saved:
		$SaveFolderSelect.popup()
		has_saved = true
	
	get_tree().change_scene_to_file(test_level)


func open_help_menu() -> void:
	$EditorHelp.visible = true


func select_song(path: String) -> void:
	var extension : String = path.get_extension()
	
	if extension == "ogg" or extension == "mp3" or extension == "wav" and ResourceLoader.exists(path):
		$Song.stream = load(path)
		data.song_path = path


func load_song_select() -> void:
	$SongSelect.popup()
