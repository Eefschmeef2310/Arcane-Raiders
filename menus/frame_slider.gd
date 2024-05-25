extends HSlider
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
@onready var fps = $"../FPS"

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	value = 241 if Engine.max_fps == 0 else Engine.max_fps
	fps.text = "Infinity" if Engine.max_fps == 0 else str(Engine.max_fps)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion


func _on_value_changed(value):
	Engine.max_fps = 0 if value == 241 else value
	fps.text = "Infinity" if value == 241 else str(value)
	
	PlayerPreferenceManager.player_preferences.max_fps = value
