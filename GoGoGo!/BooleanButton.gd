extends Button

@export var off_text : String = "off"
@export var on_text : String = "on"
@export var signal_to_connect : String = "debug"

var is_on : bool = false

func _on_pressed() -> void:
	if not is_on:
		self.text = on_text
	else:
		self.text = off_text
	
	is_on = not is_on
	Globals.emit_signal(signal_to_connect, is_on)

func switch_on() -> void:
	self.text = on_text
	is_on = true

func switch_off() -> void:
	self.text = off_text
	is_on = false
