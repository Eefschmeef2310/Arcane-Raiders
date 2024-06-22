extends Polygon2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var gradient : Gradient

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	if owner.get_parent().get_parent().get_parent() is CastleClimb:
		var castle_climb : CastleClimb = owner.get_parent().get_parent().get_parent()
		color = gradient.sample(float(castle_climb.current_floor) / float(castle_climb.total_floors))
	
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
