extends CharacterBody2D

var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
		"up": Vector2.UP, "down": Vector2.DOWN}

var tile_size = 256
var move_speed = 16
var moving = false
var health = 10
var is_dead : bool = false
var respawnTime=0
var totalRespawnTime=60

@onready var ray = $WallDetector

'''
-- READY --
'''
func _ready():
	pass

func _physics_process(delta):
	if(is_dead):
		respawnTime-=1
		if(respawnTime<=0):
			get_tree().reload_current_scene()

'''
-- UNHANDLED INPUT --
- moves the player when they press a certain key (WASD and arrow keys)
- it's called unhandled to deal with GUI easier (GUI takes higher priority)
'''
func _unhandled_input(event):
	if moving or is_dead: # so it can't change directions in the middle of its animation
		return
	
	for direction in inputs.keys():
		if event.is_action_pressed(direction):
			move(direction)
	

'''
-- MOVE --
- moves the player in one singular direction if possible
'''
func move(direction):
	
	# makes sure player can't move on top of a "wall"
	ray.target_position = inputs[direction] * tile_size
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		# move player to another tile
		var move_animation = create_tween()
		var move_direction = inputs[direction] * tile_size
		
		move_animation.tween_property(self, "position",
		(position + move_direction),
		1.0/move_speed).set_trans(Tween.TRANS_BOUNCE)
		
		# player can't move while animation plays
		moving = true
		await move_animation.finished
		moving = false

'''
-- GET DAMAGED --
- kills the player (will damage them later)
'''
func get_damaged(_area):
	if(!is_dead):
		respawnTime=totalRespawnTime
	is_dead = true
	$temporarySprite.color = "#FF0000"
	print("haha you died")
	
