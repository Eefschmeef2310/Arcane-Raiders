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
		
	#For Ethan to emulate a 1080p laptop size
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_size(Vector2(1135,638))
	
	load_preferences()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func load_preferences():
	for index in range(player_preferences.bus_volumes.size()):
		AudioServer.set_bus_volume_db(index, player_preferences.bus_volumes[index])
	
	#Set fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if player_preferences.full_screen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	#Vsync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if player_preferences.v_sync else DisplayServer.VSYNC_DISABLED)
	
	#Max FPS+
	Engine.max_fps = 0 if player_preferences.max_fps == 0 else player_preferences.max_fps
	
	#Resolution
	DisplayServer.window_set_size(player_preferences.resolution)
		
func save():
	ResourceSaver.save(player_preferences, save_path)
#endregion
