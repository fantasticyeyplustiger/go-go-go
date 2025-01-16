extends Button

var is_on : bool = false
var direction : Globals.directions = Globals.directions.DOWN

func _on_pressed() -> void:
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		remove_pulse()
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reverse_order()
		return
	
	if not is_on:
		is_on = true
		direction = Globals.directions.DOWN
		$Sprite.frame = 1
	
	elif $Sprite.frame == 5 or direction == Globals.directions.UP:
		remove_pulse()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		direction += 1
		$Sprite.frame += 1
	
	Globals.emit_signal("bg_pulse", is_on, direction)
	

func reverse_order():
	
	if not is_on:
		is_on = true
		direction = Globals.directions.UP
		$Sprite.frame = 5
		Globals.emit_signal("bg_pulse", is_on, direction)
	
	elif $Sprite.frame == 1 or direction == Globals.directions.DOWN:
		remove_pulse()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		direction -= 1
		$Sprite.frame -= 1


func remove_pulse():
	is_on = false
	direction = Globals.directions.DOWN
	$Sprite.frame = 0
	
	Globals.emit_signal("bg_pulse", is_on, direction)
