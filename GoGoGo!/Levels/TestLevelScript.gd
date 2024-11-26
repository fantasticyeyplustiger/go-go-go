extends Node2D

@export var rows : int = 0
@export var columns : int = 0
@export var row_attack_spot_limit : int = 0
@export var column_attack_spot_limit : int = 0
@export var wave : int = 0
@export var bpm : float

@onready var audio = $Music

var tile_size = 256

var start_music : bool = true
var start_wave : bool = true

var row_attacks
var column_attacks

var down_row_start : Vector2 = $DownRowStart.position
var up_row_start : Vector2 = $UpRowStart.position
var right_col_start : Vector2 = $RightColumnStart.position
var left_col_start : Vector2 = $LeftColumnStart.position

var spawn_positions : Array[Vector2] = []
var local_positions : Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	
	
	
	pass # Replace with function body.

func spawn_at(x : int, y : int, control_node : Control):
	for i in rows:
		
		var spawn_pos : Vector2 = Vector2(x * i, y * i) + control_node.position
		
		spawn_positions.append(spawn_pos)
		
		var local_pos : Vector2 = Vector2(
			roundi(spawn_pos.x - control_node.position.x) / tile_size,
			roundi(spawn_pos.y - control_node.position.y) / tile_size
		)
		
		local_positions.append(local_pos)
		
		'''
		new_child.local_position = Vector2(
			(roundi(new_child.global_position.x - $ButtonOrigin.position.x)) / tile_size,
			(roundi(new_child.global_position.y - $ButtonOrigin.position.y)) / tile_size)
		'''
		pass
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
