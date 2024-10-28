extends Button

var attack : bool = false
var index : int
var direction : Globals.directions


func _on_pressed() -> void:
	attack = not attack
	
	match attack:
		true:
			self.text = "ON"
		false:
			self.text = "OFF"
