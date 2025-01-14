extends Control

## CREDITS TO "Phantasy Dev" ON YOUTUBE

@onready var spectrum = AudioServer.get_bus_effect_instance(1, 0)
@onready var bottom_left = $Control/Control.get_children()
@onready var top_left = $Control2/Control.get_children()
@onready var bottom_right = $Control3/Control.get_children()
@onready var top_right = $Control4/Control.get_children()

const VU_COUNT = 20 # The amount of rectangles to manipulate.
const FREQ_MAX = 11050.0
const MIN_DB = 60

var HEIGHT : int = 1800

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_left.reverse()
	bottom_right.reverse()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var previous_hertz = 0
	for i in range(1, VU_COUNT + 1):
		var hertz = i * FREQ_MAX / VU_COUNT
		var frequency = spectrum.get_magnitude_for_frequency_range(previous_hertz, hertz)
		var energy = clamp((MIN_DB + linear_to_db( frequency.length() ) ) / MIN_DB, 0, 1)
		var height = energy * HEIGHT
		
		previous_hertz = hertz
		
		var bottom_left_equalizer = bottom_left[i - 1]
		var top_left_equalizer = top_left[i - 1]
		var bottom_right_equalizer = bottom_right[i - 1]
		var top_right_equalizer = top_right[i - 1]
		
		# If there is only one tween, the tween may free itself before making another tween property.
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		var tween3 = get_tree().create_tween()
		var tween4 = get_tree().create_tween()
		
		tween.tween_property(bottom_left_equalizer, "size", Vector2(height, size.y), 0.05)
		tween2.tween_property(top_left_equalizer, "size", Vector2(height, size.y), 0.05)
		tween3.tween_property(bottom_right_equalizer, "size", Vector2(height, size.y), 0.05)
		tween4.tween_property(top_right_equalizer, "size", Vector2(height, size.y), 0.05)
	


func set_height(new_height : int) -> void:
	HEIGHT = new_height
