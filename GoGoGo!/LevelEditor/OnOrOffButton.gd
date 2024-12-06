extends Button

enum setting {NONE, BOULDER, STEEL_BALL, PELLET, IRON_PELLET}

var current_setting = setting.NONE
var attack : bool = false
var type : Globals.obstacle_types = Globals.obstacle_types.BOULDER

var local_position : Vector2

func _ready() -> void:
	pass

func _on_pressed() -> void:
	
	match current_setting:
		setting.NONE:
			attack = true
			type = Globals.obstacle_types.BOULDER
			current_setting = setting.BOULDER
			$BoulderSprite.visible = true
		
		setting.BOULDER:
			type = Globals.obstacle_types.STEEL_BALL
			current_setting = setting.STEEL_BALL
		
		setting.STEEL_BALL:
			type = Globals.obstacle_types.ROCK_PELLET
			current_setting = setting.PELLET
		
		setting.PELLET:
			type = Globals.obstacle_types.IRON_PELLET
			current_setting = setting.IRON_PELLET
		
		setting.IRON_PELLET:
			attack = false
			current_setting = setting.NONE
		
	
	Globals.emit_signal("instruct", local_position, type, attack)

func switch_on():
	$BoulderSprite.visible = true
	attack = true
