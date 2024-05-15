extends CharacterBody2D

var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
		"up": Vector2.UP, "down": Vector2.DOWN}

var tile_size = 256
var move_speed = 16
var moving = false
var health = 5

@onready var ray = $WallDetector

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
	if moving: # so it can't change directions in the middle of its animation
		return
	
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

'''
-- MOVE --
- moves the player in one singular direction if possible
'''
func move(dir):
	
	# makes sure player can't move on top of a "wall"
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		# move player to another tile
		var tween = create_tween()
		
		tween.tween_property(self, "position",
		position + (inputs[dir] * tile_size),
		1.0/move_speed).set_trans(Tween.TRANS_BOUNCE)
		
		# player can't move while animation plays
		moving = true
		await tween.finished
		moving = false


