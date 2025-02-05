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

#endregion

#region Godot methods
func _ready():
	if !OS.has_feature("editor"):
		for input in InputMap.get_actions():
			if input.contains("debug_"):
				InputMap.erase_action(input)
	queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
