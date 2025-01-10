extends Control

@onready var http_request = $HTTPRequest
@onready var text_edit = $MarginContainer/VBoxContainer/TextEdit
@onready var warning = $MarginContainer/VBoxContainer/WarningLabel
var url : String
var api : String = "https://api.vevioz.com/api/button/mp3/"

func on_submit() -> void:
	
	warning.add_theme_color_override("font_color", Color(255, 0, 0, 1))
	
	url = text_edit.text
	
	if url.begins_with("https://www.youtube.com/watch?v="):
		url = url.erase(0, 32)
	elif url.begins_with("www.youtube.com/watch?v="):
		url = url.erase(0, 24)
	elif url.begins_with("youtube.com/watch?v="):
		url = url.erase(0, 20)
	
	if not url.length() == 11:
			
			warning.text = "Typo exists or Youtube ID is not 11 digits long!"
			return
	
	warning.add_theme_color_override("font_color", Color(255, 255, 255, 1))
	warning.text = "Attempting to import..."
	
	
	
	http_request.request(url)


func http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass # Replace with function body.
