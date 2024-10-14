extends AudioStreamPlayer2D
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
	#TODO - test online
	if (owner.data as PlayerData).character.animal_sound:
		(stream as AudioStreamRandomizer).set_stream(0, (owner.data as PlayerData).character.animal_sound)
#endregion



#region Signal methods


#endregion

#region Other methods (please try to separate and organise!)

#endregion
