extends Node
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
var player_preferences : PlayerPreferences
var save_path : String = "user://preferences.tres"

#endregion

#region Godot methods
func _enter_tree():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if(FileAccess.file_exists(save_path)):
		player_preferences = ResourceLoader.load(save_path) as PlayerPreferences
	else:
		player_preferences = PlayerPreferences.new()
		player_preferences.init()
		
	load_preferences()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func load_preferences():
	for index in range(player_preferences.bus_volumes.size()):
		AudioServer.set_bus_volume_db(index, player_preferences.bus_volumes[index])
		
func save():
	ResourceSaver.save(player_preferences, save_path)
#endregion
