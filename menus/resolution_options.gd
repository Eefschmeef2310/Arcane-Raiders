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
var resolutions : Array = [
		["1280x720", Vector2(1278, 718)],
		["1600x900", Vector2(1598, 998)],
		["1920x1080", Vector2(1920-2, 1080-2)],
		["2560x1440", Vector2(2560-2, 1440-2)],
		["3840x2160", Vector2(3840-2, 2160-2)]
	]


#endregion

#region Godot methods
func _ready():
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
	var size = resolutions[index][1]
	DisplayServer.window_set_size(size)
	
	PlayerPreferenceManager.player_preferences.resolution = DisplayServer.window_get_size()
