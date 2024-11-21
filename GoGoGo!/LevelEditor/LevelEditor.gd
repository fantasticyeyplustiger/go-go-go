extends Control

var tile_size : int = 256
var bpm : float = 0
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var data : Globals.levelData = Globals.levelData.new()

var current_beat : int = 0
var old_beat : int
var is_playing : bool = false
var buttons : Array[Button]

var song_length : int
var song : AudioStreamPlayer
var beat_length : float
var total_beats : int

var chart_has_changed : bool = false

@export var rows : int = 6
@export var columns : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	song = $Song
	song_length = song.stream.get_length()
	bpm = 90
	
	initialize_chart()
	
	
	Globals.instruct.connect(set_attack)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons($DownRowStart.position, Globals.directions.UP, tile_size, 0, $DownRowStart)
	load_buttons($UpRowStart.position, Globals.directions.DOWN, tile_size, 0, $UpRowStart)
	load_buttons($RightColumnStart.position, Globals.directions.RIGHT, 0, tile_size, $RightColumnStart)
	load_buttons($LeftColumnStart.position, Globals.directions.LEFT, 0, tile_size, $LeftColumnStart)


func _process(delta: float) -> void:
	old_beat = current_beat
	
	current_beat += int(Input.is_action_just_released("wheel_up")) - int(Input.is_action_just_released("wheel_down"))
	current_beat += int(Input.is_action_just_released("up")) - int(Input.is_action_just_released("down"))
	
	if not (old_beat == current_beat):
		save_attacks()
	
	
	if current_beat < 0:
		current_beat = 0
	
	var beat_label = $MarginContainer/BottomGUI/Labels/BeatLabel
	beat_label.text = "Beat: " + str(current_beat)
	
	bpm = $MarginContainer/Buttons/SpinBox.value


func load_buttons(starting_position : Vector2, direction : Globals.directions, x : int,
				 y : int, control_node : Control) -> void:
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		control_node.add_child(new_child)
		buttons.push_back(new_child)
		new_child.position = Vector2(x * i, y * i)
		new_child.local_position = Vector2(
			(new_child.global_position.x - $ButtonOrigin.position.x) / tile_size,
			(new_child.global_position.y - $ButtonOrigin.position.y) / tile_size)


'''
Sets an attack at the corresponding location to an instruction.
'''
func set_attack(local_position : Vector2, attack : bool):
	
	if attack:
		data._add_event(current_beat, Globals.obstacle_types.BOULDER, local_position)
	else:
		data._remove_event(current_beat, Globals.obstacle_types.BOULDER, local_position)
	
	chart_has_changed = true

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE


'''
Adds the saved instruction after the user goes to another beat.
If there is already a saved instruction at the current beat, it'll overwrite it.
'''
func save_attacks() -> void:
	
	if check_all_buttons_off():
		return
	
	
	
	# remove attack on this current beat and overwrite it


func initialize_chart() -> void:
	
	var temp_bpm = bpm / 4
	beat_length = (60 / temp_bpm)
	total_beats = song_length / beat_length
	
	var sprite : Sprite2D = $Empty
	
	for i in song_length:
		$ItemList.add_item(str(i), sprite.texture, true)


func check_all_buttons_off() -> bool:
	
	for button in buttons:
		if button.text == "ON":
			return false
	
	return true

'''
Turns every button off and disables their boulder sprites.
'''
func reset_buttons_to_false() -> void:
	print(buttons.size())
	for button in buttons:
		button.text = "OFF"
		button.get_child(0).visible = false
		button.attack = false


func quit() -> void:
	get_tree().quit


func play() -> void:
	
	match is_playing:
		false:
			$MarginContainer/Buttons/PlayButton.text = "PLAY"
		true:
			$MarginContainer/Buttons/PlayButton.text = "PAUSE"
	
	pass # Replace with function body.


func change_chart(index : int) -> void:
	current_beat = index
	chart_has_changed = false
	
	print(current_beat)
	
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
	


func set_button_at(position):
	for button in buttons:
		if button.local_position == position:
			button.switch_on()
