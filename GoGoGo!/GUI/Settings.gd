extends Control

@export var back_button_exists : bool = false

func _ready() -> void:
	Globals.load_settings()
	
	change_all_audio_bus_values() # Called at title screen since this scene exists in menu scene as well
	
	# Percents are being multiplied by 100 each so they are... whole numbers.
	_on_master_slider_value_changed(Globals.master_volume_percent * 100)
	_on_music_slider_value_changed(Globals.music_volume_percent * 100)
	_on_music_slider_value_changed(Globals.sfx_volume_percent * 100)
	
	$Settings/VBoxContainer/MasterSlider.value = Globals.master_volume_percent * 100
	$Settings/VBoxContainer/MusicSlider.value = Globals.music_volume_percent * 100
	$Settings/VBoxContainer/SFXSlider.value = Globals.sfx_volume_percent * 100
	
	if not Globals.boulder_sfx:
		$Settings/VBoxContainer/HBoxContainer/BooleanButton.switch_off()
	if not Globals.setting_player_sfx:
		$Settings/VBoxContainer/HBoxContainer2/BooleanButton.switch_off()
	
	if back_button_exists:
		$BackButton.visible = true
	
	# The functions beforehand turn disabled to true, so this is needed.
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", false)
	
func apply_changes() -> void:
	Globals.save_settings()
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", true)
	
	change_all_audio_bus_values()

func change_all_audio_bus_values() -> void:
	change_audio_bus_values("Master", Globals.master_volume_percent)
	change_audio_bus_values("Music", Globals.music_volume_percent)
	change_audio_bus_values("SFX", Globals.sfx_volume_percent)

func change_audio_bus_values(bus_name : String, new_percent : float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if new_percent == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_volume_linear(bus_index, new_percent)

#region set values when sliders are changed
func _on_master_slider_value_changed(value: float) -> void:
	Globals.master_volume_percent = value / 100
	$Settings/VBoxContainer/MasterVolume.text = "Master Volume: " + str(int(value))
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", false)

func _on_music_slider_value_changed(value: float) -> void:
	Globals.music_volume_percent = value / 100
	$Settings/VBoxContainer/MusicVolume.text = "Music Volume: " + str(int(value))
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", false)

func _on_sfx_slider_value_changed(value: float) -> void:
	Globals.sfx_volume_percent = value / 100
	$Settings/VBoxContainer/SFXVolume.text = "SFX Volume: " + str(int(value))
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", false)
#endregion

func boolean_button_pressed() -> void:
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", false)

## self explanatory code (boring)
func test_music() -> void:
	$Music.play()
	$TestingArea/VBoxContainer/HBoxContainer1/TestSound.set_deferred("disabled", true)
	$TestingArea/VBoxContainer/HBoxContainer1/StopSound.set_deferred("disabled", false)

func test_sfx() -> void:
	$SFX.play()
	$TestingArea/VBoxContainer/HBoxContainer2/TestSound.set_deferred("disabled", true)
	$TestingArea/VBoxContainer/HBoxContainer2/StopSound.set_deferred("disabled", false)

func stop_music() -> void:
	$Music.stop()
	$TestingArea/VBoxContainer/HBoxContainer1/TestSound.set_deferred("disabled", false)
	$TestingArea/VBoxContainer/HBoxContainer1/StopSound.set_deferred("disabled", true)

func stop_sound() -> void:
	$SFX.stop()
	$TestingArea/VBoxContainer/HBoxContainer2/TestSound.set_deferred("disabled", false)
	$TestingArea/VBoxContainer/HBoxContainer2/StopSound.set_deferred("disabled", true)

func go_back() -> void:
	self.visible = false
