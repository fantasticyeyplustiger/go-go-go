extends Button

enum bright_level {LOW = 90, MED = 145, HIGH = 200, MAX = 255}

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
	
	if brightness >= bright_level.MAX or current_texture == 3:
		set_low()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		brightness += 55
		current_texture += 1
		self.icon = textures[current_texture]
	
	Globals.emit_signal("gradient_brightness", brightness)
	

func reverse_order():
	
	if brightness == bright_level.LOW:
		brightness = bright_level.MAX
		current_texture = 3
		self.icon = textures[3]
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		brightness -= 55
		current_texture -= 1
		self.icon = textures[current_texture]


func set_low():
	brightness = bright_level.LOW
	current_texture = 0
	self.icon = textures[0]
	
	Globals.emit_signal("gradient_brightness", brightness)


func change_sprite(new_brightness : int):
	match new_brightness:
		90:
			self.icon = textures[0]
		145:
			self.icon = textures[1]
		200:
			self.icon = textures[2]
		255:
			self.icon = textures[3]
