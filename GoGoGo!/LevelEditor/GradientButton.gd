extends Button

enum bright_level {LOW = 75, MED = 175, HIGH = 225, MAX = 255}

var is_on : bool = false
var brightness : bright_level = bright_level.LOW

var textures : Array[Texture2D]
var current_texture : int = 0

func _ready() -> void:
	for child in self.get_children():
		textures.append(child.texture)
		child.queue_free()


func _on_pressed() -> void:
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		set_low()
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reverse_order()
		return
	
	if not is_on:
		is_on = true
		@warning_ignore("int_as_enum_without_cast")
		brightness += 1
		current_texture = 0
		self.icon = textures[0]
	
	elif brightness >= bright_level.MAX:
		set_low()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		brightness += 1
		current_texture += 1
		self.icon = textures[current_texture]
	
	# CALL SIGNAL TO ADD 
	

func reverse_order():
	
	if not is_on:
		is_on = true
		brightness = bright_level.MAX
		current_texture = 3
		self.icon = textures[3]
	
	elif brightness >= bright_level.LOW:
		set_low()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		brightness -= 1
		current_texture -= 1
		self.icon = textures[current_texture]


func set_low():
	is_on = false
	brightness = bright_level.LOW
	current_texture = 0
	self.icon = textures[0]
	
	# call signal that removes pulse
