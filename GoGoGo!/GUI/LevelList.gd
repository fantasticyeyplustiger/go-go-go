extends Node

class_name MainLevels

var levels : PackedStringArray
var path : String = "res://MainLevels/"

func _init() -> void:
	levels = [
		path + "SkyHigh.ggg",
		path + "RulerOfReality.ggg",
		path + "MrOops.ggg",
		path + "SkyHighRandom.ggg",
		path + "RulerOfRealityRandom.ggg",
		path + "MrOopsRandom.ggg"
	]
	
