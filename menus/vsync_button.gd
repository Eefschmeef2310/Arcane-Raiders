extends CheckBox
#Authored by Ethan. Please consult for any modifications or major feature requests.

func _ready():
	button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

#region Signal methods
func _on_toggled(toggled_on):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)
	
	PlayerPreferenceManager.player_preferences.v_sync = toggled_on
#endregion
