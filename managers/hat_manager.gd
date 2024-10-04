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
@export var hats : Dictionary

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func get_hat_from_string(s : String) -> PackedScene:
	if hats.has(s):
		return hats[s].duplicate()
	return null
#endregion
