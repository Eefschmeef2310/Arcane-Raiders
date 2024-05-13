extends HSlider
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var bus_name : String

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var bus_index : int
#endregion

#region Godot methods
func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
#endregion

#region Signal methods
func _on_value_changed(_value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	PlayerPreferenceManager.player_preferences.bus_volumes[bus_index] = linear_to_db(value)
#endregion
