extends OptionButton
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
var resolutions : Array
#endregion

#region Godot methods
func _ready():
	var exclusive = 0
	resolutions = [
		["1280x720", Vector2(1280-exclusive, 720-exclusive)],
		["1600x900", Vector2(1600-exclusive, 1000-exclusive)],
		["1920x1080", Vector2(1920-exclusive, 1080-exclusive)],
		["2560x1440", Vector2(2560-exclusive, 1440-exclusive)],
		["3840x2160", Vector2(3840-exclusive, 2160-exclusive)]
	]
	
	for r in range(resolutions.size()):
		add_item(resolutions[r][0])
		if (DisplayServer.window_get_size() as Vector2) == resolutions[r][1]:
			selected = r
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion


func _on_item_selected(index):
	if index > -1:
		var size = resolutions[index][1]
		DisplayServer.window_set_size(size)
		
		PlayerPreferenceManager.player_preferences.resolution = DisplayServer.window_get_size()
		
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
