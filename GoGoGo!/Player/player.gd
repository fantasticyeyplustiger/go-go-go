extends CharacterBody2D

var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
		"up": Vector2.UP, "down": Vector2.DOWN}

var tile_size = 256
var move_speed = 16
var moving = false
var health = 20
var is_dead : bool = false
var is_dashing : bool = false

@onready var ray = $WallDetector
@onready var dash_ray = $DashDetector

'''
-- READY --
'''
func _ready():
	pass

func _physics_process(_delta):
	if Input.is_action_pressed("dash"):
		is_dashing = true
	else:
		is_dashing = false

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
	
	var dash_multiplier = 1
	
	# makes sure player can't move on top of a "wall"
	ray.target_position = inputs[direction] * tile_size
	dash_ray.target_position = inputs[direction] * tile_size * 2
	
	ray.force_raycast_update()
	dash_ray.force_raycast_update()
	
	if not dash_ray.is_colliding() and is_dashing:
		dash_multiplier = 2
	
	if not ray.is_colliding():
		# move player to another tile
		move_speed = move_speed * dash_multiplier
		
		var move_animation = create_tween()
		var move_direction = inputs[direction] * (tile_size * dash_multiplier)
		
		move_animation.tween_property(self, "position",
		(position + move_direction),
		1.0/move_speed).set_trans(Tween.TRANS_BOUNCE)
		
		# play player sfx
		Globals.player_sfx.emit()
		
		# player can't move while animation plays
		moving = true
		await move_animation.finished
		
		
		if is_dashing:
			await get_tree().create_timer(0.001).timeout
			moving = false
		else:
			moving = false
		
		move_speed = 16

func get_damaged(damage : int):
	
	if is_dashing and moving:
		return
	
	health -= damage
	
	if health <= 0:
		is_dead = true
		$temporarySprite.color = "#FF0000"
	else:
		$temporarySprite.color = "#FFA500"
	
	$HP.text = str(health)


func laser_damage(_area) -> void:
	get_damaged(10)

func ball_damage(_area) -> void:
	get_damaged(5)

func pellet_damage(_area) -> void:
	get_damaged(1)
