extends Control

var tile_size : int = 256
var bpm : float = 0
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var level_instruction_set : Array[Instruction]
var instruction : Instruction = Instruction.new()
var data : Globals.levelData = Globals.levelData.new()

var current_beat : int = 0
var old_beat : int
var is_playing : bool = false
var buttons : Array[Button]

@export var rows : int = 6
@export var columns : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	Globals.instruct.connect(set_attack)
	
	instruction.fill_arrays_false(instruction.down_row, rows)
	instruction.fill_arrays_false(instruction.up_row, rows)
	instruction.fill_arrays_false(instruction.left_column, columns)
	instruction.fill_arrays_false(instruction.right_column, columns)
	
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
	
	var beat_label = $MarginContainer/VBoxContainer/BeatLabel
	beat_label.text = "Beat: " + str(current_beat)
	
	bpm = $MarginContainer/VBoxContainer/SpinBox.value

func load_buttons(starting_position : Vector2, direction : Globals.directions, x : int, y : int, control_node : Control):
	
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
func set_attack(local_position):
	
	data._add_event(current_beat, Globals.obstacle_types.BOULDER, local_position)

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE

'''
Adds the saved instruction after the user goes to another beat.
If there is already a saved instruction at the current beat, it'll overwrite it.
'''
func save_attacks() -> void:
	
	overwrite_instruction()
	
	instruction.has_changed = false
	instruction.beat_index = old_beat
	level_instruction_set.push_back(instruction)
	
	
	

func reset_buttons_to_false() -> void:
	print(buttons.size())
	for button in buttons:
		button.text = "OFF"
		button.attack = false


func check_for_instruction():
	for instruction in level_instruction_set:
		if instruction.beat_index == current_beat:
			return true
		
	
	return false

'''
Checks if an instruction on this beat already exists and has been changed.
If it does, it removes it so it can be overwritten.
'''
func overwrite_instruction():
	
	for instruction in level_instruction_set:
		
		if instruction.beat_index == old_beat and instruction.has_changed:
			
			level_instruction_set.remove_at(old_beat)
			break

'''
The set amount of attacks that will happen on a certain beat.
'''
class Instruction:
	
	var up_row : Array[bool]
	var left_column : Array[bool]
	var down_row : Array[bool]
	var right_column : Array[bool]
	
	var beat_index : int
	
	var has_changed : bool
	
	func fill_arrays_false(array : Array[bool], array_size : int):
		for i in array_size:
			array.push_back(false)

func quit() -> void:
	get_tree().quit


func play() -> void:
	
	reset_buttons_to_false()
	
	match is_playing:
		false:
			$MarginContainer/VBoxContainer/PlayButton.text = "PLAY"
		true:
			$MarginContainer/VBoxContainer/PlayButton.text = "PAUSE"
	
	pass # Replace with function body.
