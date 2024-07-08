extends Polygon2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var colors : Gradient

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

func _ready():
	_on_timer_timeout()

#region Signal methods
func _on_timer_timeout():
	color = colors.sample(randf())
#endregion
