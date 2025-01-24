extends Button

var is_on : bool = false

func _on_pressed() -> void:
	if not is_on:
		self.text = "GRADIENT\nPULSE\nON"
	else:
		self.text = "gradient\npulse\noff"
	
	is_on = not is_on
	Globals.emit_signal("gradient_pulse", is_on)

func switch_on() -> void:
	self.text = "GRADIENT\nPULSE\nON"
	is_on = true

func switch_off() -> void:
	self.text = "gradient\npulse\noff"
	is_on = false
