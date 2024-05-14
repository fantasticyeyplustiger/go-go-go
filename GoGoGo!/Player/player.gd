extends CharacterBody2D

var tile_size = 256
var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
		"up": Vector2.UP, "down": Vector2.DOWN}

'''
-- READY --
- sets the position of the player to the center
- called once player is instanced
'''
func _ready():
	
	#position = position.snapped(Vector2.ONE * tile_size)
	#position += Vector2.ONE * (tile_size/2)
	pass
	

'''
-- UNHANDLED INPUT --
- moves the player when they press a certain key (WASD and arrow keys)
- it's called unhandled to deal with GUI easier (GUI takes higher priority)
'''
func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

'''
-- MOVE --
- moves the player in one singular direction instantly
'''
func move(dir):
	position += inputs[dir] * tile_size
