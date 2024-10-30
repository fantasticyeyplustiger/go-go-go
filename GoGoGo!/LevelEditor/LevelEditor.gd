extends Control

var tile_size : int = 256
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var level_instruction_set : Array[Instruction]
var instruction : Instruction

var current_beat : int = 0

@export var rows : int = 6
@export var columns : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# there are buttons at the ends of every row and column.
	# activating one allows you to add an obstacle at that position.
	# this, in turn, will set its corresponding position in a button array
	# 
	
	instruction.fill_arrays_false(instruction.down_row, rows)
	instruction.fill_arrays_false(instruction.up_row, rows)
	instruction.fill_arrays_false(instruction.left_column, columns)
	instruction.fill_arrays_false(instruction.right_column, columns)
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_row($DownRowStart.position, Globals.directions.UP)
	load_row($UpRowStart.position, Globals.directions.DOWN)
	
	pass # Replace with function body.



func load_row(starting_position : Vector2, direction : Globals.directions):
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		new_child.index = i
		new_child.direction = direction
		
		new_child.pressed.connect(set_attack.bind(new_child.index, new_child.direction))

func set_attack(index : int, direction : Globals.directions):
	
	match direction:
		
		Globals.directions.LEFT:
			instruction.left_column[index] = true
		
		Globals.directions.RIGHT:
			instruction.right_column[index] = true
		
		Globals.directions.UP:
			instruction.up_row[index] = true
		
		Globals.directions.DOWN:
			instruction.down_row[index] = true

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE

func check_attacks():
	
	check_for_instruction(current_beat)
	
	instruction.beat_index = current_beat
	
	level_instruction_set.push_back(instruction)
	
	
	
	pass

'''
Checks if an instruction on this beat already exists. If it does, it removes it so it can be overwritten.
'''
func check_for_instruction(current_beat : int):
	
	for i in level_instruction_set.size():
		
		if level_instruction_set[i].beat_index == current_beat:
			
			level_instruction_set.remove_at(i)

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
