extends Node

class_name MainLevels

var levels : PackedStringArray
var path : String = "res://MainLevels/"

func _init() -> void:
	levels = [
		path + "SkyHigh.ggg",
		path + "MrOops.ggg",
		path + "Filibuster.ggg",
		path + "SkyHighRandom.ggg",
		path + "MrOopsRandom.ggg",
		path + "FilibusterRandom.ggg"
	]
	
