extends PauseMenu

const tip_1 : String = "Don't forget you have a dash!"
const tip_2 : String = "If you aren't playing a randomized level,\nyou can always memorize a path."
const tip_3 : String = "Even if you have a dash,\nyou shouldn't spam it."
const tip_4 : String = "The main levels' attacks never change. Ever."

const tips : PackedStringArray = [tip_1, tip_2, tip_3, tip_4]

func _ready() -> void:
	var random = randi_range(0, 3)
	$MarginContainer/VBoxContainer/Tip.text = "Tip: " + tips[random]

func _unhandled_input(_event: InputEvent) -> void:
	pass
