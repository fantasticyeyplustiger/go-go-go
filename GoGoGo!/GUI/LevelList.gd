extends Node

class_name MainLevels

var levels : PackedStringArray
var path : String = "res://MainLevels/"

func _init() -> void:
	var os_name = OS.get_name()
	if not os_name == "Linux" or not os_name == "X11":
		levels = [
			path + "SkyHigh.ggg",
			path + "RulerOfReality.ggg",
			path + "MrOops.ggg",
			path + "SkyHighRandom.ggg",
			path + "RulerOfRealityRandom.ggg",
			path + "MrOopsRandom.ggg"
		]
		return
	else:
		levels = [
			path + "SkyHigh",
			path + "RulerOfReality",
			path + "MrOops",
			path + "SkyHighRandom",
			path + "RulerOfRealityRandom",
			path + "MrOopsRandom"
		]
	
	
