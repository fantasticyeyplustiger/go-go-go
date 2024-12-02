extends Button

var attack : bool = false

var local_position : Vector2

func _ready() -> void:
	pass

func _on_pressed() -> void:
	attack = not attack
	
	match attack:
		true:
			$BoulderSprite.visible = true
		false:
			$BoulderSprite.visible = false
	
	Globals.emit_signal("instruct", local_position, attack)
	print(local_position)

func switch_on():
	$BoulderSprite.visible = true
	attack = true
