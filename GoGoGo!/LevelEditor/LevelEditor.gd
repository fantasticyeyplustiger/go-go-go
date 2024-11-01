extends Control

var tile_size : int = 256
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var level_instruction_set : Array[Instruction]
var instruction : Instruction = Instruction.new()

var current_beat : int = 0
var is_playing : bool = false

@export var rows : int = 6
@export var columns : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# there are buttons at the ends of every row and column.
	# activating one allows you to add an obstacle at that position.
	# this, in turn, will set its corresponding position in a button array
	#
	
	Globals.instruct.connect(set_attack)
	
	instruction.fill_arrays_false(instruction.down_row, rows)
	instruction.fill_arrays_false(instruction.up_row, rows)
	instruction.fill_arrays_false(instruction.left_column, columns)
	instruction.fill_arrays_false(instruction.right_column, columns)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_buttons($DownRowStart.position, Globals.directions.UP, 256, 0, $DownRowStart)
	load_buttons($UpRowStart.position, Globals.directions.DOWN, 256, 0, $UpRowStart)
	load_buttons($RightColumnStart.position, Globals.directions.RIGHT, 0, 256, $RightColumnStart)
	load_buttons($LeftColumnStart.position, Globals.directions.LEFT, 0, 256, $LeftColumnStart)


func load_buttons(starting_position : Vector2, direction : Globals.directions, x : int, y : int, control_node : Control):
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		control_node.add_child(new_child)
		new_child.index = i
		new_child.direction = direction
		new_child.position = Vector2(x * i, y * i)
		
		print(new_child.position)
		#new_child.pressed.connect(set_attack.bind(new_child.index, new_child.direction))

func set_attack(index : int, direction : Globals.directions):
	
	match direction:
		
		Globals.directions.LEFT:
			instruction.left_column[index] = not instruction.left_column[index]
		
		Globals.directions.RIGHT:
			instruction.right_column[index] = not instruction.right_column[index]
		
		Globals.directions.UP:
			instruction.up_row[index] = not instruction.up_row[index]
		
		Globals.directions.DOWN:
			instruction.down_row[index] = not instruction.down_row[index]

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE

func check_attacks():
	
	check_for_instruction(current_beat)
	
	instruction.beat_index = current_beat
	
	level_instruction_set.push_back(instruction)
	

'''
Checks if an instruction on this beat already exists. If it does, it removes it so it can be overwritten.
'''
func check_for_instruction(current_beat : int):
	
	for i in level_instruction_set.size():
		
		if level_instruction_set[i].beat_index == current_beat:
			
			level_instruction_set.remove_at(i)
			break

class Instruction:
	
	var up_row : Array[bool]
	var left_column : Array[bool]
	var down_row : Array[bool]
	var right_column : Array[bool]
	
	var beat_index : int
	
	func fill_arrays_false(array : Array[bool], array_size : int):
		for i in array_size:
			array.push_back(false)

func quit():
	get_tree().quit


func play() -> void:
	
	match is_playing:
		false:
			$MarginContainer/VBoxContainer/PlayButton.text = "PLAY"
		true:
			$MarginContainer/VBoxContainer/PlayButton.text = "PAUSE"
	
	pass # Replace with function body.
