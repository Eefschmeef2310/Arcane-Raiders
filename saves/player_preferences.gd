extends Resource
class_name PlayerPreferences
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export_group("Sound")
@export var bus_volumes : Array[float]

#endregion

func init():
	bus_volumes.resize(3)
	for index in range(bus_volumes.size()):
		bus_volumes[index] = linear_to_db(0.5)
	
	PlayerPreferenceManager.save()
