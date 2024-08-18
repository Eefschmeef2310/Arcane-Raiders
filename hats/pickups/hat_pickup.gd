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
@export var hat : PackedScene

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
	player.add_child(hat.instantiate())
#endregion
