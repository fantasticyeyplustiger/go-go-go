extends Button

@export var off_text : String = "off"
@export var on_text : String = "on"
@export var signal_to_connect : String = "get_new_bpm"
@export var is_on : bool = false

func _ready() -> void:
	change_spaces_to_next_lines(off_text, true)
	change_spaces_to_next_lines(on_text, false)
	

func change_spaces_to_next_lines(string : String, change_off_text : bool) -> void:
	
	var new_string : String = ""
	
	for i in string.length():
		if string[i] == " ":
			new_string += "\n"
		else:
			new_string += string[i]
	
	if change_off_text:
		off_text = new_string
	else:
		on_text = new_string


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
