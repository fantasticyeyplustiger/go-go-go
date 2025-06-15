extends Control


func apply_changes() -> void:
	Globals.save_settings()
	$Settings/VBoxContainer/ApplyChanges.set_deferred("disabled", true)

#region set values when sliders are changed
func _on_master_slider_value_changed(value: float) -> void:
	Globals.master_volume_percent = int(value)
	$Settings/VBoxContainer/MasterVolume.text = "Master Volume: " + str(int(value))

func _on_music_slider_value_changed(value: float) -> void:
	Globals.music_volume_percent = int(value)
	$Settings/VBoxContainer/MusicVolume.text = "Music Volume: " + str(int(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	Globals.sfx_volume_percent = int(value)
	$Settings/VBoxContainer/SFXVolume.text = "SFX Volume: " + str(int(value))
#endregion
