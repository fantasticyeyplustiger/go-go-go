extends Button

enum setting {NONE = 0, BOULDER = 1, PELLET = 2, STEEL_BALL = 3, IRON_PELLET = 4, LASER = 5}

var current_setting = setting.NONE
var attack : bool
var type : Globals.obstacle_types = Globals.obstacle_types.BOULDER

var local_position : Vector2

func _on_pressed() -> void:
	
	$AnimatedSprite2D.frame += 1
	attack = true
	
	match current_setting:
		setting.NONE:
			type = Globals.obstacle_types.BOULDER
			current_setting = setting.BOULDER
		
		setting.BOULDER:
			type = Globals.obstacle_types.ROCK_PELLET
			current_setting = setting.PELLET
		
		setting.PELLET:
			type = Globals.obstacle_types.STEEL_BALL
			current_setting = setting.STEEL_BALL
		
		setting.STEEL_BALL:
			type = Globals.obstacle_types.IRON_PELLET
			current_setting = setting.IRON_PELLET
		
		setting.IRON_PELLET:
			current_setting = setting.LASER
			type = Globals.obstacle_types.BOULDER
			
		
		setting.LASER:
			attack = false
			current_setting = setting.NONE
			type = Globals.obstacle_types.BOULDER
			$AnimatedSprite2D.frame = 0
		
		_:
			# YES THIS DEFAULT CASE IS NEEDED AND I HATE IT
			@warning_ignore("int_as_enum_without_cast")
			current_setting += 1
			
			@warning_ignore("int_as_enum_without_cast")
			type += 1
			
			if current_setting > 5 or type > 4:
				
				current_setting = setting.NONE
				type = Globals.obstacle_types.BOULDER
				
				$AnimatedSprite2D.frame = 0
	
	Globals.emit_signal("instruct", local_position, attack, type)


func switch_off():
	attack = false
	current_setting = setting.NONE
	$AnimatedSprite2D.frame = 0


func switch_on(new_type):
	$AnimatedSprite2D.frame = new_type + 1
	current_setting = new_type + 1
	type = new_type
	
	attack = true
