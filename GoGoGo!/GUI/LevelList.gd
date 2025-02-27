extends Node

class_name MainLevels

var levels : PackedStringArray
var start : String = "res://MainLevels"

func _ready() -> void:
	
	levels = [
		start + "SkyHigh",
		start + "MrOops",
		start + "Filibuster"
	]
	
