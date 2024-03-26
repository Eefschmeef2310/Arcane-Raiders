extends MovementBase
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
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	set_direction(Input.get_vector("Left", "Right", "Up", "Down"))
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
