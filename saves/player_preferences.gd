extends Resource
class_name PlayerPreferences
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export_group("Sound")
@export var bus_volumes : Array[float]

@export_group("Graphics")
@export var full_screen : bool
@export var v_sync : bool
@export var max_fps : int
@export var resolution : Vector2

#endregion

func init():
	bus_volumes.resize(3)
	for index in range(bus_volumes.size()):
		bus_volumes[index] = linear_to_db(0.5)
		
	full_screen = true
	v_sync = true
	max_fps = 60
	resolution = Vector2(1980, 1080)
	
	PlayerPreferenceManager.save()
