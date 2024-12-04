extends Control

var tile_size : int = 256
var bpm : float
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var data : Globals.levelData = Globals.levelData.new()
var copy_data : Array[Vector2] = []

var current_beat : int = 0
var old_beat : int
var is_playing : bool = false
var buttons : Array[Button]

var song_length : int
var song : AudioStreamPlayer
var beat_length : float
var total_beats : int

var chart_has_changed : bool = false
var is_saving : bool = false
var is_loading : bool = false

@export var rows : int = 6
@export var columns : int = 6


func _ready():
	
	song = $Song
	song_length = song.stream.get_length()
	bpm = 180
	
	initialize_chart()
	
	$ItemList.select(0, true)
	
	Globals.instruct.connect(set_attack)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons($DownRowStart.position, tile_size, 0, $DownRowStart)
	load_buttons($UpRowStart.position, tile_size, 0, $UpRowStart)
	load_buttons($RightColumnStart.position, 0, tile_size, $RightColumnStart)
	load_buttons($LeftColumnStart.position, 0, tile_size, $LeftColumnStart)
	


func _physics_process(delta: float) -> void:
	
	var beat_label = $MarginContainer/BottomGUI/Labels/BeatLabel
	beat_label.text = "Beat: " + str(current_beat)
	
	if chart_has_changed:
		$MarginContainer/Buttons/SaveButton.disabled = false


func load_buttons(starting_position : Vector2, x : int, y : int, control_node : Control) -> void:
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		control_node.add_child(new_child)
		buttons.push_back(new_child)
		new_child.position = Vector2(x * i, y * i)
		new_child.local_position = Vector2(
			(roundi(new_child.global_position.x - $ButtonOrigin.position.x)) / tile_size,
			(roundi(new_child.global_position.y - $ButtonOrigin.position.y)) / tile_size)
		


'''
Sets an attack at the corresponding location or deactivates it.
Called by OnOrOffButton being pressed.
'''
func set_attack(local_position : Vector2, attack : bool):
	
	if attack:
		data._add_event(current_beat, Globals.obstacle_types.BOULDER, local_position)
		$ItemList.set_item_icon(current_beat, $Boulder.texture)
	
	else:
		data._remove_event(current_beat, Globals.obstacle_types.BOULDER, local_position)
		
		
		if check_all_buttons_off():
			$ItemList.set_item_icon(current_beat, $Empty.texture)
	
	chart_has_changed = true


func initialize_chart() -> void:
	
	beat_length = (60 / bpm)
	total_beats = song_length / beat_length
	
	var sprite : Sprite2D = $Empty
	
	for i in song_length:
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
		button.get_child(0).visible = false
		button.attack = false


func quit() -> void:
	get_tree().quit
	self.queue_free()


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
	
	


'''
Grabs the part of the chart you've changed to, saves the one you were at,
and loads changed chart. Resets all buttons to false if the loaded chart is empty.
'''
func change_chart(index : int) -> void:
	
	current_beat = index
	chart_has_changed = false
	
	var exists : bool = false
	var attacks : Array[Vector2] = []
	
	for i in total_buttons:
		exists = data._check_event_exists(current_beat, 0, buttons[i].local_position)
		
		if exists:
			reset_buttons_to_false()
			attacks = data._get_event_positions(current_beat, Globals.obstacle_types.BOULDER)
			break
	
	if attacks.size() == 0:
		reset_buttons_to_false()
		return
	
	for data in attacks:
		set_button_at(data)
	

'''
Turns on a specific button with the position given.
'''
func set_button_at(position):
	for button in buttons:
		if button.local_position == position:
			button.switch_on()


func for_every_beat() -> void:
	
	current_beat += 1
	if current_beat > song_length:
		$PlayTimer.stop()
	
	$ItemList.select(current_beat, true)
	$ItemList.ensure_current_is_visible()
	change_chart(current_beat)
	

func copy_attacks() -> void:
	
	var exists : bool
	
	for i in total_buttons:
		#exists cant detect loaded events?
		exists = data._check_event_exists(current_beat, 0, buttons[i].local_position)
		
		if exists:
			copy_data = data._get_event_positions(current_beat, Globals.obstacle_types.BOULDER)
			break
	
	$MarginContainer/Buttons/PasteButton.disabled = false

func paste_attacks() -> void:
	
	reset_buttons_to_false()
	
	for data in copy_data:
		set_attack(data, true)
		set_button_at(data)


func save() -> void:
	$SaveFolderSelect.popup()

func load_data() -> void:
	$LoadSaveSelect.popup()

func load_save_file(path: String) -> void:
	
	data = Globals.levelData.new()
	
	for i in $ItemList.item_count:
		$ItemList.set_item_icon(i, $Empty.texture)
	
	data._load(path)
	reset_buttons_to_false()
	
	var iterator : int = 0
	
	for event in data.events:
		
		var event_position : Vector2 = Vector2(event.x, event.y)
		$ItemList.set_item_icon(event.timing, $Boulder.texture)
		
		set_button_at(event_position)

func save_folder_selected(path: String) -> void:
	var file = $SaveFolderSelect.current_file
	data.save(path, false)
