extends CheckBox
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

func _ready():
	button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

#region Signal methods
func _on_toggled(toggled_on):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	
	#Move window such that the top bar isn't above the screen - Ethan 9/2/25
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		# Get the current window
		var window = get_window()
		# And get the current screen the window's in
		var screen = window.current_screen
		# Get the usable rect for that screen
		var screen_rect = DisplayServer.screen_get_usable_rect(screen)
		# Get the window's size
		var window_size = window.get_size_with_decorations()
		# Set its position to the middle
		window.position = screen_rect.position + (screen_rect.size / 2 - window_size / 2)
		
	$"../OptionButton"._on_item_selected($"../OptionButton".selected)
	
	PlayerPreferenceManager.player_preferences.full_screen = toggled_on
	
#endregion
