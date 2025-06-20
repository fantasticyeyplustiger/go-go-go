extends PauseMenu

func _ready() -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	pass

func set_attempt_count(attempts : int) -> void:
	$MarginContainer/VBoxContainer/AttemptCount.text = "Total Attempt Count for this run: " + str(attempts - 1)
