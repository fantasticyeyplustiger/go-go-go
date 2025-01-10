extends Button

enum setting {NONE = 0, BOULDER = 1, PELLET = 2, STEEL_BALL = 3, IRON_PELLET = 4, LASER = 5}

var current_setting = setting.NONE
var attack : bool
var reverse : int = 1
var type : Globals.obstacle_types = Globals.obstacle_types.BOULDER

var local_position : Vector2i

func _on_pressed() -> void:
	
	attack = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		$AnimatedSprite2D.frame = 0
		
		current_setting = setting.NONE
		type = Globals.obstacle_types.BOULDER
		
		attack = false
		
		Globals.emit_signal("instruct", local_position, attack, type)
		
		return
	
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reverse_type()
		return
	
	$AnimatedSprite2D.frame += 1
	
	if not current_setting == setting.NONE:
		@warning_ignore("int_as_enum_without_cast")
		type += 1
	
	if current_setting == setting.NONE and type > 0:
		type = Globals.obstacle_types.BOULDER
	
	@warning_ignore("int_as_enum_without_cast")
	current_setting += 1
	
	if current_setting > setting.LASER or type > Globals.obstacle_types.LASER:
		
		attack = false
		
		current_setting = setting.NONE
		type = Globals.obstacle_types.BOULDER
		
		$AnimatedSprite2D.frame = 0
	
	Globals.emit_signal("instruct", local_position, attack, type)


func reverse_type():
	
	if current_setting == setting.NONE:
		
		current_setting = setting.LASER
		type = Globals.obstacle_types.LASER
		
		$AnimatedSprite2D.frame = 5
		
	else:
		if not type == 0:
			@warning_ignore("int_as_enum_without_cast")
			type -= 1
		
		@warning_ignore("int_as_enum_without_cast")
		current_setting -= 1
		
		$AnimatedSprite2D.frame -= 1
	
	if current_setting == setting.NONE:
		attack = false
	
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
