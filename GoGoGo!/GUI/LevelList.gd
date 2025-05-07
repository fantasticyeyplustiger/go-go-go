extends Node

class_name MainLevels

var levels : PackedStringArray
var path : String = "res://MainLevels/"

func _init() -> void:
	levels = [
		path + "SkyHigh",
		path + "MrOops",
		path + "Filibuster",
		path + "SkyHighRandom",
		path + "MrOopsRandom",
		path + "FilibusterRandom"
	]
	
