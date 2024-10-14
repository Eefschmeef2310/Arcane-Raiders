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
#endregion



#region Signal methods
func _on_player_data_character_updated():
	if (get_parent().data as PlayerData).character.animal_sound != null:
		(stream as AudioStreamRandomizer).set_stream(0, (get_parent().data as PlayerData).character.animal_sound)
#endregion
