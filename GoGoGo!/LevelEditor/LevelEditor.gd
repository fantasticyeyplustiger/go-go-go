extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var new_child = load(self.get_path()).instantiate()
	load_row(new_child, $DownRowStart.position)
	load_row(new_child, $UpRowStart.position)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_row(child, starting_position : Vector2):
	
	
	
	pass

func quit():
	get_tree().quit
