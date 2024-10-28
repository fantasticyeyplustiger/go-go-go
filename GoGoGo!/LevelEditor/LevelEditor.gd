extends Control

var tile_size : int = 256
var on_or_off_button_path = "res://LevelEditor/OnOrOffButton.tscn"
var total_buttons : int
var level_instruction_set : Array[Array]

var up_row : Array[bool]
var left_column : Array[bool]
var down_row : Array[bool]
var right_column : Array[bool]

var current_beat : int = 0

@export var rows : int = 6
@export var columns : int = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# there are buttons at the ends of every row and column.
	# activating one allows you to add an obstacle at that position.
	# this, in turn, will set its corresponding position in a button array
	# 
	
	total_buttons = (2 * rows) + (2 * columns)
	
	load_row($DownRowStart.position, Globals.directions.UP)
	load_row($UpRowStart.position, Globals.directions.DOWN)
	
	pass # Replace with function body.



func load_row(starting_position : Vector2, direction : Globals.directions):
	
	for i in rows:
		var new_child = load(on_or_off_button_path).instantiate()
		
		new_child.index = i
		new_child.direction = direction
		

# ONCE USER GOES TO ANOTHER BEAT, CHECK EVERY BUTTON'S ATTACK VARIABLE





func quit():
	get_tree().quit
