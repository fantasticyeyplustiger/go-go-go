extends Control


func _ready() -> void:
	get_text_from_file()


func get_text_from_file() -> void:
	
	var help_file = FileAccess.open("res://LevelEditor/EditorHelp.txt", FileAccess.READ)
	
	$MarginContainer/ScrollContainer/VBoxContainer/RichTextLabel.text = help_file.get_as_text(false)


func close_help_menu() -> void:
	self.visible = false
