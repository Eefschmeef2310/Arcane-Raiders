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
var rates : Array = [
		["1280x720", Vector2(1280, 720)],
		["1600x900", Vector2(1600, 900)],
		["1920x1080", Vector2(1920, 1080)],
		["2560x1440", Vector2(2560, 1440)],
		["3840x2160", Vector2(3840, 2160)]
	]


#endregion

#region Godot methods
func _ready():
	for r in range(rates.size()):
		add_item(rates[r][0])
		if (DisplayServer.window_get_size() as Vector2) == rates[r][1]:
			selected = r
#endregion

#region Signal methods
func _on_item_selected(index):
	var size = rates[index][1]
	DisplayServer.window_set_size(size)
#endregion

#region Other methods (please try to separate and organise!)

#endregion



