extends Control

var tile_size : int = 256
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var level_instruction_set : Array[Instruction]
var instruction : Instruction = Instruction.new()

var current_beat : int = 0
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


func load_buttons(starting_position : Vector2, direction : Globals.directions, x : int, y : int, control_node : Control):
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		control_node.add_child(new_child)
		buttons.push_back(new_child)
		new_child.index = i
		new_child.direction = direction
		new_child.position = Vector2(x * i, y * i)
		
		#print(new_child.position)

'''
Sets an attack at the corresponding location to an instruction.
'''
func set_attack(index : int, direction : Globals.directions):
	
	match direction:
		
		Globals.directions.LEFT:
			instruction.left_column[index] = not instruction.left_column[index]
			#print(instruction.left_column[index])
		
		Globals.directions.RIGHT:
			instruction.right_column[index] = not instruction.right_column[index]
			#print(instruction.right_column[index])
		
		Globals.directions.UP:
			instruction.up_row[index] = not instruction.up_row[index]
			#print(instruction.up_row[index])
		
		Globals.directions.DOWN:
			instruction.down_row[index] = not instruction.down_row[index]
			#print(instruction.down_row[index])

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE

'''
Adds the saved instruction after the user goes to another beat.
If there is already a saved instruction at the current beat, it'll overwrite it.
'''
func save_attacks() -> void:
	
	overwrite_instruction(current_beat)
	
	instruction.beat_index = current_beat
	level_instruction_set.push_back(instruction)
	

func reset_buttons_to_false() -> void:
	print(buttons.size())
	for button in buttons:
		button.text = "OFF"
		button.attack = false

'''
Checks if an instruction on this beat already exists. If it does, it removes it so it can be overwritten.
'''
func overwrite_instruction(current_beat : int):
	
	for i in level_instruction_set.size():
		
		if level_instruction_set[i].beat_index == current_beat:
			
			level_instruction_set.remove_at(i)
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
