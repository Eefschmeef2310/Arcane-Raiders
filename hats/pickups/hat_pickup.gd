extends HatPickup
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var hat_string : String

	#Onready Variables

	#Other Variables (please try to separate and organise!)


#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func pickup_function(player):
	super.pickup_function(player)
	if hat_string:
		player.add_child(HatManager.get_hat_from_string(hat_string).instantiate())
#endregion
