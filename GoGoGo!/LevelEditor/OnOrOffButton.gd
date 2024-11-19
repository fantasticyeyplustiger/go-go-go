extends Button

var attack : bool = false

var local_position : Vector2

func _ready() -> void:
	pass

func _on_pressed() -> void:
	attack = not attack
	
	match attack:
		true:
			self.text = "ON"
		false:
			self.text = "OFF"
	print(local_position)
	Globals.emit_signal("instruct", local_position)
