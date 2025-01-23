extends Button

enum height_level {LOW = 1200, MED = 1850, HIGH = 2500, MAX = 3150}

var height : height_level = height_level.LOW

var textures : Array[Texture2D]
var current_texture : int = 0

func _ready() -> void:
	textures.append(load("res://Sprites/EqualizerLow.png"))
	textures.append(load("res://Sprites/EqualizerMed.png"))
	textures.append(load("res://Sprites/EqualizerHigh.png"))
	textures.append(load("res://Sprites/EqualizerMax.png"))


func _on_pressed() -> void:
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		set_low()
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reverse_order()
		return
	
	if height >= height_level.MAX or current_texture == 3:
		set_low()
		return
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		height += 650
		current_texture += 1
		self.icon = textures[current_texture]
	
	Globals.emit_signal("equalizer_height", height)
	

func reverse_order():
	
	if height == height_level.LOW:
		height = height_level.MAX
		current_texture = 3
		self.icon = textures[3]
	
	else:
		@warning_ignore("int_as_enum_without_cast")
		height -= 650
		current_texture -= 1
		self.icon = textures[current_texture]
	
	Globals.emit_signal("equalizer_height", height)


func set_low():
	height = height_level.LOW
	current_texture = 0
	self.icon = textures[0]
	Globals.emit_signal("equalizer_height", height)


func change_sprite(new_height) -> void:
	
	match new_height:
		1200:
			self.icon = textures[0]
		1850:
			self.icon = textures[1]
		2500:
			self.icon = textures[2]
		3150:
			self.icon = textures[3]
