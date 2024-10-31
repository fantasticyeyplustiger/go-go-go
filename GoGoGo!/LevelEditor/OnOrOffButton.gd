extends Button

var attack : bool = false
var index : int
var direction : Globals.directions

func _ready() -> void:
	
	Globals.signals.connect(Globals.instruct)
	
	
	pass

func _on_pressed() -> void:
	attack = not attack
	
	match attack:
		true:
			self.text = "ON"
		false:
			self.text = "OFF"
	
	Globals.emit_signal("instruct", index, direction)
